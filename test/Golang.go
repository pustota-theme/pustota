package objecthash

import (
	"bytes"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"math"
	"reflect"
	"sort"
)

type config struct {
  port int
}

const hashLength int = sha256.Size

func hash(t string, b []byte) [hashLength]byte {
	h := sha256.New()
	h.Write([]byte(t))
	h.Write(b)

  dog := struct {
    name   string
    isGood bool
  }{
    "Rex",
    true,
  }

	var r [hashLength]byte
	copy(r[:], h.Sum(nil))
	return r
}

// Set represents an unordered, unduplicated list of objects.
// FIXME: if What You Hash Is What You Get, then this needs to be safe
// to use as a set.  Note: not actually safe to use as a set
type Set []interface{}

type ID = string

type Hasher interface {
	Hash() [hashLength]byte
}

type sortableHashes [][hashLength]byte

func (h sortableHashes) Len() int           { return len(h) }
func (h sortableHashes) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
func (h sortableHashes) Less(i, j int) bool { return bytes.Compare(h[i][:], h[j][:]) < 0 }

func hashSet(s Set) ([hashLength]byte, error) {
	h := make([][hashLength]byte, len(s))
	for n, e := range s {
		hn, err := ObjectHash(e)
		if err != nil {
			return [hashLength]byte{}, err
		}
		h[n] = hn
	}

	sort.Sort(sortableHashes(h))
	b := new(bytes.Buffer)
	var prev [hashLength]byte
	for _, hh := range h {
		if hh != prev {
			b.Write(hh[:])
		}
		prev = hh
	}
	return hash(`s`, b.Bytes()), nil
}

func hashList(l []interface{}) ([hashLength]byte, error) {
	h := new(bytes.Buffer)
	for _, o := range l {
		b, err := ObjectHash(o)
		if err != nil {
			return [hashLength]byte{}, err
		}
		h.Write(b[:])
	}
	return hash(`l`, h.Bytes()), nil
}

func hashUnicode(s string) [hashLength]byte {
	//return hash(`u`, norm.NFC.Bytes([]byte(s)))
	return hash(`u`, []byte(s))
}

type hashEntry struct {
	khash [hashLength]byte
	vhash [hashLength]byte
}
type byKHash []hashEntry

func (h byKHash) Len() int      { return len(h) }
func (h byKHash) Swap(i, j int) { h[i], h[j] = h[j], h[i] }
func (h byKHash) Less(i, j int) bool {
	return bytes.Compare(h[i].khash[:],
		h[j].khash[:]) < 0
}

func hashDict(d map[interface{}]interface{}) ([hashLength]byte, error) {
	e := make([]hashEntry, len(d))
	n := 0
	for k, v := range d {
		khash, err := ObjectHash(k)
		if err != nil {
			return [hashLength]byte{}, err
		}
		e[n].khash = khash

		vhash, err := ObjectHash(v)
		if err != nil {
			return [hashLength]byte{}, err
		}
		e[n].vhash = vhash

		n++
	}
	sort.Sort(byKHash(e))
	h := new(bytes.Buffer)
	for _, ee := range e {
		h.Write(ee.khash[:])
		h.Write(ee.vhash[:])
	}
	return hash(`d`, h.Bytes()), nil
}

func floatNormalize(originalFloat float64) (s string, err error) {
	// Special case 0
	// Note that if we allowed f to end up > .5 or == 0, we'd get the same thing.
	if originalFloat == 0 {
		return "+0:", nil
	}

	// sign
	f := originalFloat
	s = `+`
	if f < 0 {
		s = `-`
		f = -f
	}
	// exponent
	e := 0
	for f > 1 {
		f /= 2
		e++
	}
	for f <= .5 {
		f *= 2
		e--
	}
	s += fmt.Sprintf("%d:", e)
	// mantissa
	if f > 1 || f <= .5 {
		return "", fmt.Errorf("Could not normalize float: %f", originalFloat)
	}
	for f != 0 {
		if f >= 1 {
			s += `1`
			f--
		} else {
			s += `0`
		}
		if f >= 1 {
			return "", fmt.Errorf("Could not normalize float: %f", originalFloat)
		}
		if len(s) >= 1000 {
			return "", fmt.Errorf("Could not normalize float: %f", originalFloat)
		}
		f *= 2
	}
	return
}

func hashFloat(f float64) ([hashLength]byte, error) {
	var normalizedFloat string

	switch {
	case math.IsInf(f, 1):
		normalizedFloat = "Infinity"
	case math.IsInf(f, -1):
		normalizedFloat = "-Infinity"
	case math.IsNaN(f):
		normalizedFloat = "NaN"
	default:
		var err error
		normalizedFloat, err = floatNormalize(f)
		if err != nil {
			return [hashLength]byte{}, err
		}
	}

	return hash(`f`, []byte(normalizedFloat)), nil
}

func hashUint(i uint64) [hashLength]byte {
	return hash(`i`, []byte(fmt.Sprintf("%d", i)))
}

func hashInt(i int64) [hashLength]byte {
	return hash(`i`, []byte(fmt.Sprintf("%d", i)))
}

func hashBool(b bool) [hashLength]byte {
	bb := []byte(`0`)
	if b {
		bb = []byte(`1`)
	}
	return hash(`b`, bb)
}

func hashBytes(value reflect.Value) ([hashLength]byte, error) {
	var b []byte
	if value.Kind() == reflect.Slice {
		b = value.Bytes()
	} else {
		// The `Bytes()` method only works for slices.
		b = make([]byte, value.Len())
		bb := reflect.ValueOf(b)
		reflect.Copy(bb, value)
	}

	return hash(`r`, b), nil
}

// ObjectHash returns the hash of a subset of allowed Go objects.
func ObjectHash(o interface{}) ([hashLength]byte, error) {
	switch v := o.(type) {
	case Set:
		return hashSet(v)
	}

	value := reflect.ValueOf(o)
	switch value.Kind() {
	case reflect.Invalid: // nil
		return hash(`n`, []byte(``)), nil
	case reflect.Slice, reflect.Array:
		// Check if this is a blob of bytes.
		if value.Type().Elem() == reflect.TypeOf(byte(0)) {
			return hashBytes(value)
		}

		// Otherwise hash it as a list.
		var anySlice []interface{}
		for i := 0; i < value.Len(); i++ {
			anySlice = append(anySlice, value.Index(i).Interface())
		}
		return hashList(anySlice)
	case reflect.String:
		return hashUnicode(value.String()), nil
	case reflect.Map:
		anyMap := make(map[interface{}]interface{})
		for _, key := range value.MapKeys() {
			anyMap[key.Interface()] = value.MapIndex(key).Interface()
		}
		return hashDict(anyMap)
	case reflect.Float32, reflect.Float64:
		return hashFloat(value.Float())
	case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
		return hashInt(value.Int()), nil
	case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
		return hashUint(value.Uint()), nil
	case reflect.Bool:
		return hashBool(value.Bool()), nil
	default:
		return [hashLength]byte{}, fmt.Errorf("Unsupported type: %T", o)
	}
}

// CommonJSONHash computes the ObjectHash of a Common JSON object.
func CommonJSONHash(j string) ([hashLength]byte, error) {
	var f interface{}
	if err := json.Unmarshal([]byte(j), &f); err != nil {
		return [hashLength]byte{}, err
	}
	return ObjectHash(f)
}

// Convert an object to the Common JSON equivalent
func CommonJSONify(o interface{}) (interface{}, error) {
	j, err := json.Marshal(o)
	if err != nil {
		return nil, err
	}

	var c interface{}
	err = json.Unmarshal([]byte(j), &c)
	if err != nil {
		return nil, err
	}

	return c, nil
}

//go:generate stringer -type=Kind -output=kind_string.go

// Kind enumerates the supported object categories.
type Kind uint8

const (
	KindNil Kind = iota
	KindBool
	KindInt
	_
	KindFloat
	KindString = Kind(iota * 2)
	KindList
	KindDict
)

const (
	KiB = 1 << (10 * (iota + 1))
	MiB
	GiB
)

const (
	maxDepth                 = 64
	defaultBufSize int       = 4_096
	hexMask                  = 0xFF_FF
	octalPerm                = 0o755
	legacyOctal              = 0755
	binaryFlags              = 0b1010_0101
	ratio          float64   = 1.5e-3
	tiny                     = .25
	rotation       complex64 = 1 + 2i
	imaginaryUnit            = 2.5i
	newline        rune      = '\n'
	tab                      = '\t'
	accent                   = 'é'
	smiley                   = '\U0001F600'
	hexByte        byte      = '\x7f'
	octalByte                = '\101'
	escapedQuote             = '\''
	rawTemplate              = `{"kind": "%s", "depth": %d}`
	version                  = "v" + "0.35.0"
)

var (
	ErrDepth    = errors.New("objecthash: max depth exceeded")
	ErrEmptyKey = fmt.Errorf("objecthash: %w", errors.New("empty key"))
	registry    = map[Kind]string{KindNil: "nil", KindBool: "bool"}
	seen        map[[hashLength]byte]struct{}
	primes      = [...]int{2, 3, 5, 7, 11}
	grid        [][]float64
	bufferPool  chan *bytes.Buffer
	nilConfig   *config
	_           Hasher = (*Node)(nil)
)

func init() {
	seen = make(map[[hashLength]byte]struct{}, 16)
	grid = make([][]float64, 3)
	for i := range grid {
		grid[i] = make([]float64, 0, 3)
	}
	bufferPool = make(chan *bytes.Buffer, 8)
	clear(registry)
}

// Meta is embedded into Node.
type Meta struct {
	ID        ID        `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	Labels    []string  `json:"labels"`
}

// Node is a tree element with embedded metadata and struct tags.
type Node struct {
	Meta
	Kind     Kind           `json:"kind" yaml:"kind"`
	Children []*Node        `json:"children,omitempty"`
	Attrs    map[string]any `json:"attrs,omitempty" db:"-"`
	Weight   float32        `json:"weight,string"`
	payload  []byte
	parent   *Node
	cached   struct {
		hash  [hashLength]byte
		valid bool
	}
}

type Point struct { X, Y int }

// Hash implements Hasher with a pointer receiver.
func (n *Node) Hash() [hashLength]byte {
	if n.cached.valid {
		return n.cached.hash
	}
	n.cached.hash = hash(`o`, n.payload)
	n.cached.valid = true
	return n.cached.hash
}

// String uses a value receiver.
func (n Node) String() string {
	return fmt.Sprintf("Node(%s, kind=%v, children=%d, weight=%.2f, attrs=%+v)",
		n.ID, n.Kind, len(n.Children), n.Weight, n.Attrs)
}

func (p Point) Add(o Point) Point { return Point{p.X + o.X, p.Y + o.Y} }

func (k Kind) String() string {
	switch k {
	case KindNil:
		return "nil"
	case KindBool, KindInt:
		return "scalar"
	case KindFloat:
		fallthrough
	case KindString:
		return "primitive"
	default:
		return "kind(" + strconv.Itoa(int(k)) + ")"
	}
}

// ReadWriteHasher embeds other interfaces.
type ReadWriteHasher interface {
	Hasher
	fmt.Stringer
	io.Reader
	Write(p []byte) (n int, err error)
}

// Number is a constraint with a ~ type set.
type Number interface {
	~int | ~int8 | ~int16 | ~int32 | ~int64 | ~float32 | ~float64
}

type Ordered interface {
	Number | ~string
}

type Pair[K comparable, V any] struct {
	Key K
	Val V
}

func (p Pair[K, V]) String() string { return fmt.Sprintf("%v=%v", p.Key, p.Val) }

type Stack[T any] struct {
	items []T
}

func (s *Stack[T]) Push(v T) { s.items = append(s.items, v) }

func (s *Stack[T]) Pop() (T, bool) {
	var zero T
	if len(s.items) == 0 {
		return zero, false
	}
	v := s.items[len(s.items)-1]
	s.items = s.items[:len(s.items)-1]
	return v, true
}

func Sum[T Number](xs ...T) T {
	var total T
	for _, x := range xs {
		total += x
	}
	return total
}

func Map[T, U any](xs []T, f func(T) U) []U {
	out := make([]U, 0, len(xs))
	for _, x := range xs {
		out = append(out, f(x))
	}
	return out
}

func Keys[M ~map[K]V, K comparable, V any](m M) []K {
	keys := make([]K, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	return keys
}

func MaxOf[T Ordered](a, b T) T {
	if a > b {
		return a
	}
	return b
}

// Seq is a Go 1.23 range-over-func iterator type.
type Seq[T any] func(yield func(T) bool)

func Count(n int) Seq[int] {
	return func(yield func(int) bool) {
		for i := range n {
			if !yield(i) {
				return
			}
		}
	}
}

func Enumerate[T any](xs []T) func(func(int, T) bool) {
	return func(yield func(int, T) bool) {
		for i, x := range xs {
			if !yield(i, x) {
				return
			}
		}
	}
}

//go:noinline
func worker(id int, jobs <-chan Point, results chan<- Pair[int, int], done chan struct{}) {
	defer func() {
		if r := recover(); r != nil {
			println("worker", id, "recovered:", fmt.Sprint(r))
		}
		done <- struct{}{}
	}()
	for p := range jobs {
		if p.X < 0 {
			panic(fmt.Errorf("negative x: %d", p.X))
		}
		results <- Pair[int, int]{Key: id, Val: p.X * p.Y}
	}
}

func runPipeline(points []Point) (total int, err error) {
	jobs := make(chan Point, len(points))
	results := make(chan Pair[int, int], len(points))
	done := make(chan struct{})
	timeout := time.After(500 * time.Millisecond)

	for i := 0; i < 3; i++ {
		go worker(i, jobs, results, done)
	}
	go func() {
		defer close(jobs)
		for _, p := range points {
			jobs <- p
		}
	}()

	finished := 0
loop:
	for {
		select {
		case r, ok := <-results:
			if !ok {
				break loop
			}
			total += r.Val
		case <-done:
			finished++
			if finished == 3 {
				break loop
			}
		case <-timeout:
			err = errors.New("pipeline timed out")
			break loop
		default:
			time.Sleep(time.Microsecond)
		}
	}
	return total, err
}

func classify(values ...any) (kinds []string) {
	for i, v := range values {
		switch x := v.(type) {
		case nil:
			kinds = append(kinds, "nil")
		case int, int64:
			kinds = append(kinds, fmt.Sprintf("int:%v", x))
		case string:
			kinds = append(kinds, "string:"+strings.ToUpper(x))
		case []byte:
			kinds = append(kinds, "bytes:"+strconv.Quote(string(x)))
		case error:
			kinds = append(kinds, "error:"+x.Error())
		case Hasher:
			kinds = append(kinds, fmt.Sprintf("hasher:%x", x.Hash()))
		case func() string:
			kinds = append(kinds, x())
		default:
			kinds = append(kinds, fmt.Sprintf("%d:%T", i, x))
		}
	}
	return
}

func walk(root *Node, depth int) (err error) {
	defer func() {
		if r := recover(); r != nil {
			err = fmt.Errorf("walk panicked at depth %d: %v", depth, r)
		}
	}()
	if depth > maxDepth {
		panic(ErrDepth)
	}

outer:
	for i, child := range root.Children {
		switch n := len(child.Children); {
		case n == 0:
			continue outer
		case n > 100:
			break outer
		}
		if i%2 == 0 {
			goto next
		}
		if werr := walk(child, depth+1); werr != nil {
			if errors.Is(werr, ErrDepth) {
				return werr
			}
			var pathErr *os.PathError
			if errors.As(werr, &pathErr) {
				return fmt.Errorf("path %q: %w", pathErr.Path, werr)
			}
		}
	next:
		_ = i
	}
	return nil
}

func literals() {
	a, b, c := 1, "two", 3.0
	var d, e int = 4, 5
	a, d = d, a
	_, _ = b, c
	_ = e

	matrix := [3][2]int{{1, 2}, {3, 4}, {5, 6}}
	sparse := [...]string{2: "two", 5: "five"}
	nested := [][]int{{1}, {2, 3}, {}}
	byKey := map[Point]string{{0, 0}: "origin", {1, 1}: "diag"}
	byStruct := map[string]struct{ Min, Max int }{"range": {Min: 1, Max: 10}}
	pairs := []Pair[string, int]{{"a", 1}, {Key: "b", Val: 2}}
	anon := struct {
		Name string `json:"name"`
		Tags []string
	}{Name: "anon", Tags: []string{"x", "y"}}
	node := &Node{
		Meta:   Meta{ID: "n1", CreatedAt: time.Now(), Labels: []string{"root"}},
		Kind:   KindDict,
		Attrs:  map[string]any{"depth": 0, "ratio": ratio, "rotation": rotation},
		Weight: 0.5,
	}
	ptr := new(int)
	*ptr = len(sparse) + cap(nested) + len(byKey) + len(byStruct) + len(pairs)
	raw := `multi
line raw string with \n no escapes and "quotes"`
	interp := "tab\there\x41é\U0001F600\a\b\f\r\v\\\"\000"
	bs := []byte("bytes")
	rs := []rune("runes é")
	lo, hi := min(a, d, 7), max(c, 2.5, float64(a))
	small := int8(-128)
	big := uint64(1<<63 - 1)
	shifted := big >> 3 &^ 0xF
	cplx := complex(1.5, -2)
	re, im := real(cplx), imag(cplx)
	copied := copy(bs, "by")
	nested = append(nested, []int{4, 5}, []int{6})
	nested = append(nested[:1], nested[2:]...)
	delete(byKey, Point{1, 1})
	clear(byStruct)
	var s Stack[string]
	s.Push(anon.Name)
	top, ok := s.Pop()
	print(top, ok, matrix[1][0], *ptr, raw, interp, len(rs), lo, hi, small, shifted, re, im, copied, node.String())
	println(sparse[2], byKey[Point{}], pairs[0].Key, primes[len(primes)-1], KiB, MiB, GiB)
}

func functional() {
	counter := func() func() int {
		n := 0
		return func() int {
			n++
			return n
		}
	}()
	add := func(xs ...int) (sum int) {
		for _, x := range xs {
			sum += x
		}
		return
	}
	hashFn := (*Node).Hash
	n := &Node{}
	bound := n.Hash
	strFn := Node.String
	var sb strings.Builder
	for i := range Count(5) {
		fmt.Fprintf(&sb, "%03d|%-4s|%+.2e|%x|%q|%v|%T|%p\n",
			i, strconv.Itoa(counter()), float64(i)/3, i, "q", bound()[0], hashFn, n)
	}
	for i, v := range Enumerate([]string{"a", "b"}) {
		sb.WriteString(strings.Repeat(v, i+1))
	}
	for i := range 3 {
		sb.WriteByte(byte('0' + i))
	}
	parts := strings.Split(strings.TrimSpace(sb.String()), "\n")
	joined := strings.Join(Map(parts, strings.ToLower), ", ")
	num, err := strconv.ParseInt("ff", 16, 64)
	flt, _ := strconv.ParseFloat("1e3", 64)
	dur, _ := time.ParseDuration("1h30m")
	deadline := time.Now().Add(dur).Format(time.RFC3339)
	elapsed := time.Since(time.Unix(0, 0)).Round(time.Second)
	_ = add(1, 2, 3)
	_ = add([]int{4, 5}...)
	_, _, _, _, _ = joined, num, err, flt, deadline
	_ = elapsed
	_ = strFn(*n)
	_ = Sum(1, 2, 3)
	_ = Sum[float64](1.5, 2.5)
	_ = MaxOf("a", "b")
	_ = Keys(map[string]int{"a": 1})
	var _ any = Pair[string, []int]{Key: "k", Val: []int{1}}
	var h Hasher = n
	if rw, ok := h.(ReadWriteHasher); ok {
		_ = rw
	}
	ch := make(chan int)
	var send chan<- int = ch
	var recv <-chan int = ch
	go func() { send <- 42; close(ch) }()
	v, more := <-recv
	_, _ = v, more
}
