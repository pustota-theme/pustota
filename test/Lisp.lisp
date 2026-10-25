(defpackage #:ultralisp/ci
  (:use #:cl)
  (:import-from #:40ants-ci/jobs/linter)
  (:import-from #:40ants-ci/workflow
                #:defworkflow)
  (:import-from #:40ants-ci/jobs/run-tests))
(in-package #:ultralisp/ci)


(defclass ultralisp-job-mixin ()
  ())


(defmethod 40ants-ci/jobs/job:steps :around ((job ultralisp-job-mixin))
  (list*
   (40ants-ci/steps/sh:sh "Install libev"
                          "sudo apt-get install libev4")
   (call-next-method )))


(defclass linter (ultralisp-job-mixin 40ants-ci/jobs/linter:linter)
  ())


(defclass run-tests (ultralisp-job-mixin 40ants-ci/jobs/run-tests:run-tests)
  ())


(defmethod 40ants-ci/github:prepare-data :around ((job run-tests))
  (list*
   '("services"
     . (("postgres"
         . (("image" . "postgres:10")
            ("env" . (("POSTGRES_USER" . "ultralisp")
                      ("POSTGRES_PASS" . "ultralisp")))
            ("options"
             . "--health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5")
            ("ports" . ("5432:5432"))))))
   (call-next-method)))


(defworkflow ci
  :on-push-to "master"
  :test 1
  :by-cron "0 10 * * 1"
  :on-pull-request t
  :cache t
  :env (("CL_SOURCE_REGISTRY" . "${{ github.workspace }}/"))
  :jobs ((linter
          :lisp "sbcl-bin/2.2.5")
         (run-tests
          :lisp "sbcl-bin/2.1.2"
          ;; Does not work because cl-coverage complains
          ;; it can't quickload app-deps. Hmmm...
          ;; :coverage nil
          )))


;;;; ---------------------------------------------------------------------------
;;;; Additional syntax coverage
;;;; ---------------------------------------------------------------------------

;;; Section-level comment.
;; Indented comment.
; Margin comment.

#|
Block comment
  #| with a nested block comment |#
still inside the outer one.
|#

(defpackage #:ultralisp/hash
  (:use #:cl)
  (:nicknames #:uhash)
  (:shadow #:digest)
  (:export #:fingerprint
           #:make-fingerprint
           #:hash-object
           #:|MixedCaseSymbol|))
(in-package #:ultralisp/hash)

(declaim (optimize (speed 3) (safety 1) (debug 0)))

(defconstant +max-depth+ 1000
  "Maximum nesting depth for HASH-OBJECT.")

(defconstant +magic+ #xDEADBEEF)

(defparameter *default-algo* :sha256
  "Algorithm used when none is supplied.")

(defvar *registry* (make-hash-table :test #'equal)
  "Maps hex digests to FINGERPRINT instances.")

(defvar *literals*
  (list 42 -17 #xFF #b1010 #o755 #36rZZ 1/3 -2/5 1.5 1.0e10 2.5d0 3.0f0 1.0s0 1.0l0
        #c(1 2) #c(1.5 -0.5)
        #\a #\Space #\Newline #\Tab #\( #\) #\; #\" #\\ #\U+00E9
        "plain string" "with \"escaped\" quotes and \\ backslash"
        "a multi
line string"
        #(1 2 3) #2A((1 2) (3 4)) #*1011 #p"/tmp/file.txt"
        :keyword 'quoted-symbol '|Symbol With Bars| 'cl::car '#:uninterned
        #'car #'(lambda (x) x) #.(+ 1 2) #+sbcl :sbcl #-sbcl :other
        '(a . b) '(1 2 . 3) `(one ,(+ 1 1) ,@(list 3 4))))

(defstruct (point (:constructor make-point (x y &optional (z 0)))
                  (:print-function (lambda (p stream depth)
                                     (declare (ignore depth))
                                     (format stream "#<point ~a,~a,~a>"
                                             (point-x p) (point-y p) (point-z p)))))
  "A 3d point."
  (x 0 :type fixnum)
  (y 0 :type fixnum)
  (z 0 :type fixnum :read-only t))

(defstruct fingerprint
  (algo *default-algo* :type keyword)
  (digest "" :type string)
  (length 0))

(defclass hashable ()
  ((algo :initarg :algo :initform *default-algo* :accessor hashable-algo :type keyword)
   (digest :initarg :digest :reader hashable-digest :documentation "Raw digest bytes.")
   (label :initarg :label :accessor hashable-label :initform nil)
   (count :allocation :class :initform 0 :accessor hashable-count))
  (:documentation "Base class for hashable things.")
  (:default-initargs :label "anonymous"))

(defclass salted-hashable (hashable)
  ((salt :initarg :salt :accessor salt)))

(defgeneric hash-object (object &key algo depth)
  (:documentation "Compute the digest of OBJECT.")
  (:method ((object null) &key algo depth)
    (declare (ignore algo depth))
    "n"))

(defmethod hash-object ((object string) &key (algo *default-algo*) (depth 0))
  (declare (type string object) (ignorable depth))
  (format nil "u:~(~a~):~a" algo object))

(defmethod hash-object ((object integer) &key algo (depth 0))
  (declare (ignore algo depth))
  (format nil "i:~d:~x:~o:~b:~8,'0d" object object object object object))

(defmethod hash-object ((object list) &key (algo *default-algo*) (depth 0))
  (when (> depth +max-depth+)
    (error "too deep: ~a" depth))
  (format nil "l:~{~a~^,~}"
          (mapcar (lambda (o) (hash-object o :algo algo :depth (1+ depth))) object)))

(defmethod hash-object :before ((object hashable) &key &allow-other-keys)
  (incf (hashable-count object)))

(defmethod hash-object :around ((object salted-hashable) &rest args &key &allow-other-keys)
  (concatenate 'string (salt object) (apply #'call-next-method object args)))

(defmethod print-object ((object hashable) stream)
  (print-unreadable-object (object stream :type t :identity t)
    (format stream "~a ~s" (hashable-algo object) (hashable-label object))))

(defmethod (setf hashable-label) :after (new-value (object hashable))
  (declare (ignore new-value))
  (setf (gethash (hashable-digest object) *registry*) object))

(defmacro with-timing ((var &optional (units 1000)) &body body)
  "Bind VAR to the elapsed time in UNITS while running BODY."
  (let ((start (gensym "START")))
    `(let ((,start (get-internal-real-time)))
       (multiple-value-prog1 (progn ,@body)
         (setf ,var (/ (- (get-internal-real-time) ,start) ,units))))))

(defmacro define-hasher (name (&rest lambda-list) &body body)
  `(progn
     (defun ,name (,@lambda-list)
       ,@body)
     (export ',name)))

(define-hasher hash-pair (a b &optional (sep #\:) &key (algo *default-algo*) verbose &allow-other-keys)
  "Hash two values joined by SEP."
  (let* ((left (hash-object a :algo algo))
         (right (hash-object b :algo algo))
         (joined (format nil "~a~c~a" left sep right)))
    (when verbose
      (format t "~&~a + ~a => ~a~%" left right joined))
    joined))

(defun hash-all (&rest objects &key (algo *default-algo*) &allow-other-keys)
  "Hash every object in OBJECTS using nested local functions."
  (flet ((strip-keys (list)
           (loop for (item . rest) on list
                 unless (keywordp item)
                   collect item
                 when (keywordp item)
                   do (pop rest))))
    (labels ((walk (items acc)
               (cond ((null items) (nreverse acc))
                     ((consp (car items))
                      (walk (cdr items) (cons (walk (car items) nil) acc)))
                     (t (walk (cdr items) (cons (hash-object (car items) :algo algo) acc))))))
      (walk (strip-keys objects) '()))))

(defun classify (value)
  "Dispatch on VALUE with every conditional form."
  (cond
    ((null value) :empty)
    ((and (integerp value) (evenp value)) :even)
    ((typep value '(or float ratio)) :real)
    ((stringp value) (if (string= value "") :blank :string))
    (t
     (case value
       ((:a :b) :letter)
       (:c :see)
       (otherwise
        (typecase value
          (symbol :symbol)
          (vector :vector)
          (t :unknown)))))))

(defun digest-size (algo)
  (ecase algo
    (:sha256 32)
    (:sha512 64)
    ((:md5 :weak) 16)))

(defun loop-examples (items)
  "Exercise LOOP, DOLIST, DOTIMES and DO."
  (let ((total 0)
        (seen '())
        (table (make-hash-table)))
    (dolist (item items)
      (push item seen))
    (dotimes (i (length items) total)
      (incf total i))
    (do ((i 0 (1+ i))
         (acc '() (cons i acc)))
        ((>= i 3) (nreverse acc))
      (setf (gethash i table) (* i i)))
    (loop for item in items
          for index from 0
          for key = (if (symbolp item) item (intern (princ-to-string item)))
          with limit = 10
          while (< index limit)
          when (numberp item)
            sum item into numeric-total
          else
            collect item into others
          count (stringp item) into string-count
          maximize (sxhash key) into biggest
          finally (return (values numeric-total others string-count biggest seen)))))

(defun values-and-handlers (input)
  "MULTIPLE-VALUE-BIND, HANDLER-CASE, UNWIND-PROTECT and RESTART-CASE."
  (multiple-value-bind (quotient remainder) (floor (length input) 3)
    (handler-case
        (restart-case
            (unwind-protect
                 (progn
                   (when (zerop quotient)
                     (error 'simple-error
                            :format-control "nothing to hash: ~s"
                            :format-arguments (list input)))
                   (unless (< remainder 3)
                     (warn "weird remainder ~d" remainder))
                   (values (hash-object input) quotient remainder))
              (setf (hashable-count (make-instance 'hashable)) 0))
          (use-default ()
            :report "Use the default fingerprint."
            (values "" 0 0)))
      (simple-error (e)
        (format *error-output* "~&error: ~a~%" e)
        nil)
      (type-error (e)
        (declare (ignore e))
        :type-error)
      (:no-error (digest q r)
        (list digest q r)))))

(defun file-example (path)
  "WITH-OPEN-FILE and WITH-OUTPUT-TO-STRING."
  (with-open-file (in path :direction :input :if-does-not-exist nil :external-format :utf-8)
    (when in
      (with-output-to-string (out)
        (loop for line = (read-line in nil nil)
              while line
              do (write-string (string-upcase line) out)
                 (terpri out))))))

(defun formatting-examples (name items)
  (format nil "~a ~s ~d ~5,2f ~x ~b ~o ~e ~$ ~c ~%~&~{~a~^, ~} ~[zero~;one~:;many~] ~:[no~;yes~] ~r ~@r ~(~a~) ~:(~a~) ~10a|~10@a|~~"
          name name 42 3.14159 255 5 8 1234.5 9.99 #\x items 2 t 4 4 "LOWER" "title case" "left" "right"))

(let* ((fp (make-fingerprint :algo :sha512 :digest "abc" :length 3))
       (obj (make-instance 'salted-hashable :salt "s-" :digest "d" :label "primary"))
       (counter 0)
       (stack (list 1 2 3))
       (plist (list :a 1 :b 2))
       (fn #'(lambda (&rest xs) (reduce #'+ xs :initial-value 0)))
       (closure (let ((n 0)) (lambda () (incf n))))
       (elapsed nil))
  (declare (ignorable fp counter elapsed))
  (setf (fingerprint-length fp) (1+ (fingerprint-length fp))
        (getf plist :c) 3
        counter (funcall closure))
  (incf counter 10)
  (decf counter)
  (push 0 stack)
  (pop stack)
  (setf (hashable-label obj) "renamed")
  (funcall fn 1 2 3)
  (apply fn (mapcar #'1+ stack))
  (assert (= counter 10) (counter) "counter was ~d" counter)
  (check-type stack list)
  (with-timing (elapsed 1000000)
    (hash-all 1 "two" '(3 (4)) :algo :sha512))
  (prog1 (hash-pair fp obj :verbose t)
    (format t "~&~a ~a ~a~%" (classify 2) (digest-size :sha256) (loop-examples '(1 "two" :three)))
    (print (values-and-handlers "abcdef"))
    (print (formatting-examples "fmt" '(1 2 3)))
    (remhash "d" *registry*)
    (let ((|MixedCaseSymbol| 1))
      (declare (special |MixedCaseSymbol|))
      (symbol-value '|MixedCaseSymbol|))))
