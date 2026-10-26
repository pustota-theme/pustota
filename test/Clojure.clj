(ns example.core
  "Namespace docstring."
  (:require [clojure.string :as str]
            [clojure.set :refer [union]])
  (:import (java.util Date UUID)))

;; Single line comment
; Another comment
#_(ignored form)
(comment
  (this is a rich comment))

;; Constants and literals
(def int-num 42)
(def float-num 3.14)
(def ratio 1/3)
(def big 123N)
(def hex 0xFF)
(def chars [\a \newline \space A])
(def flags [true false nil])
(def kw :keyword)
(def ns-kw ::namespaced)
(def sym 'symbol)
(def text "string with \"escapes\" \n")
(def pattern #"\d+[a-z]*")
(def ^:private ^:dynamic *config* {:debug false})

;; Collections
(def a-list '(1 2 3))
(def a-vector [1 2 3])
(def a-map {:name "Ann" :age 30})
(def a-set #{1 2 3})

;; Functions
(defn greet
  "Greets someone."
  ([] (greet "world"))
  ([name]
   (str "Hello, " name "!")))

(defn- private-helper [x] (* x 2))

(defn destructure [{:keys [name age] :or {age 0}} & rest]
  [name age rest])

(def anonymous (fn [x] (inc x)))
(def short-fn #(+ % %2))

;; Macros
(defmacro unless [test & body]
  `(if (not ~test) (do ~@body)))

;; Protocols, records, and types
(defprotocol Shape
  (area [this]))

(defrecord Circle [radius]
  Shape
  (area [_] (* Math/PI radius radius)))

(deftype Point [x y])

(defmulti speak :kind)
(defmethod speak :dog [_] "Woof")

;; Control flow
(defn classify [n]
  (cond
    (neg? n) :negative
    (zero? n) :zero
    :else :positive))

(let [x 1
      y (if (> x 0) "pos" "neg")]
  (when-let [z (seq [x])]
    (case y
      "pos" (println "positive" z)
      (println "other"))))

(loop [i 0]
  (when (< i 10)
    (recur (inc i))))

(doseq [n (range 3)]
  (println n))

(for [x (range 5) :when (odd? x)] (* x x))

;; Threading
(->> (range 10)
     (filter even?)
     (map inc)
     (reduce +))

(-> {:a 1}
    (assoc :b 2)
    (update :a inc))

;; Java interop
(.toUpperCase "text")
(Date.)
(new UUID 0 0)
(System/currentTimeMillis)

;; Exceptions
(try
  (throw (ex-info "Boom" {:code 1}))
  (catch Exception e
    (println (ex-message e)))
  (finally
    (println "done")))

;; Atoms and reader macros
(def counter (atom 0))
(swap! counter inc)
@counter
#inst "2024-01-01T00:00:00.000-00:00"
#uuid "00000000-0000-0000-0000-000000000000"
