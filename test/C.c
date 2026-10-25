#include <assert.h>
#include <json-c/json.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "unicode/utypes.h"
#include "unicode/localpointer.h"
#include "unicode/uset.h"
#include "unicode/unorm2.h"
#include "unicode/ustring.h"

#include "objecthash.h"

#define MACRO(VAR) \
  hash_update((VAR))

struct student
{
    char name[50];
    int roll;
    float marks;
} s;

typedef struct {
    uint16_t sl_id;
    uint16_t sl_flags;
    uint32_t _reserved;  // must be 0
    union {
        void *sl_ptr;
        void (*sl_func)(void);
        Py_ssize_t sl_size;
        int64_t sl_int64;
        uint64_t sl_uint64;
    };
} PySlot;

typedef struct _object PyObject;

PyAPI_FUNC(void) PyObject_ClearWeakRefs(PyObject *);

typedef Py_hash_t (*hashfunc)(PyObject *);
typedef PyObject *(*richcmpfunc) (PyObject *, PyObject *, int);

enum Color chosenColor = GREEN;
struct Point pt = { 10, 20 };
union DataValue val;

int
PyList_Append(PyObject *op, PyObject *newitem)
{
    if (PyList_Check(op) && (newitem != NULL)) {
        int ret;
        Py_BEGIN_CRITICAL_SECTION(op);
        ret = _PyList_AppendTakeRef((PyListObject *)op, Py_NewRef(newitem));
        Py_END_CRITICAL_SECTION();
        return ret;
    }
    PyErr_BadInternalCall();
    return -1;
}

bool object_hash(/*const*/ json_object *j, byte hash[HASH_SIZE]);

static void hash_update(hash_ctx * const c, const byte * const b,
                        const size_t l) {
  SHA256_Update(c, b, l);
}

static void hash_init(hash_ctx * const c, const byte t) {
  SHA256_Init(c);

  byte b[1];
  b[0] = t;
  hash_update(c, b, 1);
}

static void hash_final(hash_ctx * const c, hash h) {
  SHA256_Final(h, c);
}

static void hash_bytes(const byte t, const byte * const b, const size_t l,
                       hash hash) {
  hash_ctx ctx;
  hash_init(&ctx, t);
  hash_update(&ctx, b, l);
  hash_final(&ctx, hash);
}

static int dict_comp(const void *a, const void *b) {
  // note that this should always terminate in < sizeof(hash) anyway
  return memcmp(a, b, 2 * sizeof(hash));
}

static bool object_hash_str(const char *str, size_t len, byte hash[HASH_SIZE]) {
  hash_bytes('u', (const byte *)str, len, hash);
  return true;
}

static bool object_hash_bool(bool b, hash h) {
  hash_bytes('b', (byte *)(b ? "1" : "0"), 1, h);
  return true;
}

static bool object_hash_dict(/*const*/ json_object * const d, hash h) {
  // FIXME: there may be a better way
  size_t len = 0;
  {
    json_object_object_foreach(d, key, val) {
      ++len;
      // key and val are unused, but we don't want the compiler to complain.
      (void)key;
      (void)val;
    }
  }
  byte *hashes = malloc(2 * len * sizeof(hash));

  size_t n = 0;
  json_object_object_foreach(d, key, val) {
    object_hash_str(key, strlen(key), &hashes[2 * n * sizeof(hash)]);
    object_hash(val, &hashes[(2 * n + 1) * sizeof(hash)]);
    ++n;
  }

  qsort(hashes, len, 2 * sizeof(hash), dict_comp);
  hash_bytes('d', hashes, 2 * len * sizeof(hash), h);

  free(hashes);

  return true;
}

static bool object_hash_int(int64_t i, hash h) {
  char buf[100];

  sprintf(buf, "%" PRId64, i);
  hash_bytes('i', (byte *)buf, strlen(buf), h);
  return true;
}

static void float_normalize(double f, char out[1000]) {
  const char * const base = out;

  // special case 0
  // Note that if we allowed f to end up > .5 or == 0, we'd get the same thing
  if (f == 0.0) {
    strcpy(out, "+0:");
    return;
  }

  // sign
  *out = '+';
  if (f < 0) {
    *out = '-';
    f = -f;
  }
  ++out;

  // exponent
  int e = 0;
  while (f > 1) {
    f /= 2;
    e += 1;
  }
  while (f <= .5) {
    f *= 2;
    e -= 1;
  }
  out += sprintf(out, "%d:", e);

  // mantissa
  assert(f <= 1);
  assert(f > .5);
  while (f != 0) {
    if (f >= 1) {
      *out++ = '1';
      f -= 1;
    } else {
      *out++ = '0';
    }
    assert (f < 1);
    assert (out - base < 1000);
    f *= 2;
  }

  *out = '\0';
}

static bool object_hash_float(const double d, hash h) {
  char buf[1000];

  float_normalize(d, buf);
  hash_bytes('f', (byte *)buf, strlen(buf), h);
  return true;
}

static bool object_hash_list(json_object *l, hash h) {
  hash_ctx ctx;
  hash_init(&ctx, 'l');

  int len = json_object_array_length(l);
  for (int n = 0; n < len; ++n) {
    byte ihash[HASH_SIZE];
    if (!object_hash(json_object_array_get_idx(l, n), ihash))
      return false;
    hash_update(&ctx, ihash, sizeof ihash);
  }

  hash_final(&ctx, h);
  return true;
}

bool object_hash(/*const*/ json_object *j, byte hash[HASH_SIZE]) {
  enum json_type type;
  type = json_object_get_type(j);
  switch (type) {
  case json_type_boolean:
    return object_hash_bool(json_object_get_boolean(j), hash);
  case json_type_double:
    return object_hash_float(json_object_get_double(j), hash);
  case json_type_int:
    return object_hash_int(json_object_get_int64(j), hash);
  case json_type_string: {
    const char *s = json_object_get_string(j);
    return object_hash_str(s, strlen(s), hash);
  }
  case json_type_object:
    return object_hash_dict(j, hash);
  case json_type_array:
    return object_hash_list(j, hash);
  case json_type_null:
    hash_bytes('n', NULL, 0, hash);
    return true;
  default:
    break;
  }
  printf("unknown type = %d\n", type);
  assert(false);
  return false;
}

bool python_json_hash(const char * const json, hash hash) {
    json_object * const j = json_tokener_parse(json);
    return object_hash(j, hash);
}

typedef json_object *leaf_fn(json_object *j);

static json_object *apply_to_leaves(json_object *j, leaf_fn *fn) {
  enum json_type type;
  type = json_object_get_type(j);
  switch (type) {
  case json_type_boolean:
  case json_type_double:
  case json_type_int:
  case json_type_null:
  case json_type_string:
    return fn(j);
  case json_type_object: {
    json_object *r = json_object_new_object();
    json_object_object_foreach(j, key, val) {
      json_object *k = json_object_new_string(key);
      json_object *kk = fn(k);
      json_object_put(k);
      const char *kkk = json_object_get_string(kk);
      json_object_object_add(r, kkk, apply_to_leaves(val, fn));
      json_object_put(kk);
    }
    return r;
  }
  case json_type_array: {
    json_object *r = json_object_new_array();
    for (int n = 0; n < json_object_array_length(j); ++n) {
      json_object_array_add(r, apply_to_leaves(json_object_array_get_idx(j, n),
					       fn));
    }
    return r;
  }
  }
  printf("type = %d\n", type);
  assert(false);
  return NULL;
}

static json_object *commonize_int(json_object *j) {
  if (json_object_get_type(j) == json_type_int)
    return json_object_new_double(json_object_get_int64(j));
  return json_object_get(j);
}

json_object *commonize(json_object *j) {
  return apply_to_leaves(j, commonize_int);
}

bool common_json_hash(const char * const json, hash hash) {
  json_object * const j = json_tokener_parse(json);
  return object_hash(commonize(j), hash);
}

static json_object *unicode_normalize_string(json_object *j) {
  if (json_object_get_type(j) == json_type_string) {
    const char *s = json_object_get_string(j);
    UErrorCode err;
    const UNormalizer2 *un = unorm2_getNFCInstance(&err);
    assert(un);
    assert(!err);

    int32_t length;
    u_strFromUTF8(NULL, 0, &length, s, strlen(s), &err);
    assert(!err);

    UChar *us = malloc(length * sizeof(UChar));
    int32_t uslength;
    u_strFromUTF8(us, length, &uslength, s, strlen(s), &err);
    assert(!err);

    // FIXME: surely we can find out how long the result will be?
    UChar *usn = malloc(uslength * 10 * sizeof(UChar));
    int32_t usnlength = unorm2_normalize(un, us, uslength, usn, 10 * uslength,
                                       &err);
    assert(!err);
    assert(usnlength <= uslength * 10);

    int32_t n8length;
    u_strToUTF8(NULL, 0, &n8length, usn, usnlength, &err);
    assert(!err);

    char *n8 = malloc(n8length);
    u_strToUTF8(n8, n8length, &n8length, usn, usnlength, &err);
    assert(!err);

    free(n8);
    free(usn);
    free(us);

    return json_object_new_string(n8);
  }
  return json_object_get(j);
}

json_object *unicode_normalize(json_object *j) {
  return apply_to_leaves(j, unicode_normalize_string);
}

static int
handle_queue_error(int err, PyObject *mod, int64_t qid)
{
    if (err == 0) {
        assert(!PyErr_Occurred());
        return 0;
    }
    assert(err < 0);
    assert((err == -1) == (PyErr_Occurred() != NULL));

    module_state *state;
    switch (err) {
    case ERR_QUEUE_ALLOC: _Py_FALLTHROUGH;
    case ERR_QUEUES_ALLOC:
        PyErr_NoMemory();
        break;
    case -1:
        return -1;
    default:
        state = get_module_state(mod);
        assert(state->QueueError != NULL);
        PyObject *exctype = NULL;
        PyObject *msg = NULL;
        if (resolve_module_errcode(state, err, qid, &exctype, &msg) < 0) {
            return -1;
        }
        PyObject *exc = PyObject_CallOneArg(exctype, msg);
        Py_DECREF(msg);
        if (exc == NULL) {
            return -1;
        }
        PyErr_SetObject(exctype, exc);
        Py_DECREF(exc);
    }
    return 1;
}

/* ------------------------------------------------------------------------ */
/* Additional syntax coverage                                                */
/* ------------------------------------------------------------------------ */

#include <stdarg.h>
#include <stdatomic.h>
#include <stddef.h>
#include <threads.h>
#include <time.h>
#include <errno.h>

#if defined(__GNUC__) && !defined(__clang__)
#  define OH_INLINE static inline __attribute__((always_inline))
#elif defined(_MSC_VER)
#  define OH_INLINE static __inline
#else
#  define OH_INLINE static inline
#endif

#ifndef OH_MAX_DEPTH
#define OH_MAX_DEPTH 64
#endif

#ifdef OH_TRACE
#  define TRACE(fmt, ...) fprintf(stderr, "[%s:%d] " fmt "\n", __FILE__, __LINE__, ##__VA_ARGS__)
#else
#  define TRACE(fmt, ...) ((void)0)
#endif

#define STR(x) #x
#define XSTR(x) STR(x)
#define CONCAT(a, b) a##b
#define ARRAY_LEN(a) (sizeof(a) / sizeof((a)[0]))
#define oh_describe(x) _Generic((x),         \
    int: "int",                              \
    unsigned int: "unsigned int",            \
    long: "long",                            \
    double: "double",                        \
    char *: "char *",                        \
    const char *: "const char *",            \
    default: "unknown")

/**
 * @brief Tagged node used by the hash tree walker.
 * @param kind  discriminator for the union below
 * @note  the trailing flexible array member holds the key bytes
 */
typedef struct oh_node {
    enum { OH_LEAF = 0, OH_BRANCH = 1 << 1, OH_ROOT = 0x10 } kind;
    unsigned int flags : 3;
    unsigned int depth : 5;
    _Bool dirty : 1;
    union {
        struct { const char *key; size_t len; } leaf;
        struct { struct oh_node *children[OH_MAX_DEPTH]; int count; } branch;
    } u;
    struct oh_node *next;
    __attribute__((aligned(16))) unsigned char scratch[16];
    byte tail[];
} oh_node_t;

static_assert(sizeof(uint32_t) == 4, "uint32_t must be 4 bytes");
_Static_assert(OH_MAX_DEPTH > 0, "depth must be positive");

typedef int (*oh_compare_fn)(const void *, const void *);
typedef void (*oh_visit_fn)(oh_node_t *restrict node, void *restrict ctx);
typedef unsigned char oh_byte;

static _Atomic int oh_live_nodes = 0;
static thread_local int oh_last_error;
static __thread int oh_tls_depth;
static volatile sig_atomic_t oh_interrupted;
extern const char *const oh_version;
register int oh_unused_reg;

static const int oh_ints[] = { 0x7fffffff, 0X1F, 0777, 0b1011, 1000000, -1, 'a', '\n', '\x41', '\0', '\'' };
static const unsigned long long oh_suffixed[] = { 42u, 42U, 42l, 42LL, 42ull, 0xFFul };
static const long double oh_floats[] = { 1e3, 1.5e-3, .5, 2.f, 1.0L, 3.14f, 0x1p4, 0x1.8p-1 };
static const wchar_t oh_wide = L'w';
static const char16_t oh_u16 = u'x';
static const char32_t oh_u32 = U'\U0001F600';
static const char *oh_str = "plain \"quoted\" \t tab \\ backslash \101 \x41 é";
static const wchar_t *oh_wstr = L"wide" L" concatenated";
static const char *oh_u8 = u8"utf-8 literal";
static const char16_t *oh_u16s = u"utf-16";
static const char32_t *oh_u32s = U"utf-32";
static const char oh_multi[] = "line one\n"
                               "line two\n"
                               XSTR(OH_MAX_DEPTH);

static struct student roster[] = {
    [0] = { .name = "Ada", .roll = 1, .marks = 97.5f },
    [2] = { .name = "Linus", .roll = 3, .marks = 88.0f },
};

static const oh_node_t oh_sentinel = {
    .kind = OH_ROOT,
    .flags = 0b101,
    .depth = 0,
    .dirty = false,
    .u.leaf = { .key = "", .len = 0 },
    .next = NULL,
};

static inline __attribute__((always_inline)) size_t oh_align_up(size_t n, size_t align) {
    return (n + align - 1) & ~(align - 1);
}

__attribute__((format(printf, 1, 2)))
static int oh_logf(const char *restrict fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    int written = vfprintf(stderr, fmt, ap);
    va_end(ap);
    return written;
}

static void oh_sum_rows(int rows, int cols, int grid[rows][cols], long *restrict out) {
    int vla[rows];
    memset(vla, 0, sizeof vla);
    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) vla[r] += abs(grid[r][c]);
        *out += vla[r];
    }
}

static void oh_visit(oh_node_t *restrict node, void *restrict ctx) {
    (void)ctx;
    if (!node) return;
    switch (node->kind) {
    case OH_LEAF:
        TRACE("leaf %.*s", (int)node->u.leaf.len, node->u.leaf.key);
        /* fall through */
    case OH_BRANCH:
        for (int i = 0; i < node->u.branch.count; i++) {
            oh_visit(node->u.branch.children[i], ctx);
        }
        break;
    case OH_ROOT:
    default:
        break;
    }
}

int oh_walk(oh_node_t *root, oh_visit_fn visit, void *ctx) {
    int depth = 0, visited = 0;
    oh_node_t *cur = root;
    oh_node_t *stack[OH_MAX_DEPTH] = { 0 };
    clock_t started = clock();

    if (root == NULL) goto done;

    do {
        if (depth >= OH_MAX_DEPTH) {
            oh_last_error = ERANGE;
            goto fail;
        }
        stack[depth++] = cur;
        visit(cur, ctx);
        visited++;
        cur = cur->next ? cur->next : (depth > 1 ? stack[depth - 2] : NULL);
    } while (cur != NULL && !oh_interrupted);

    for (;;) {
        if (depth-- <= 0) break;
        stack[depth] = NULL;
    }

    size_t i = 0;
    while (i < ARRAY_LEN(stack)) {
        if (stack[i] != NULL) {
            i++;
            continue;
        }
        break;
    }

    atomic_fetch_add(&oh_live_nodes, visited);
    oh_tls_depth = depth;
    fprintf(stdout, "walked %d nodes in %.3f s\n", visited,
            (double)(clock() - started) / CLOCKS_PER_SEC);
    return visited;

fail:
    oh_logf("walk failed at depth %d (%s): %s\n", depth, oh_describe(depth), strerror(errno));
    return -1;
done:
    return 0;
}

static uint32_t oh_mix(uint32_t h, uint32_t k) {
    k *= 0xcc9e2d51u;
    k = (k << 15) | (k >> 17);
    k *= 0x1b873593;
    h ^= k;
    h = (h << 13) | (h >> (32 - 13));
    h = h * 5 + 0xe6546b64;
    h &= ~0u;
    h |= 0;
    h >>= 0;
    h <<= 0;
    h %= 0xffffffffu;
    h /= 1;
    h -= 0;
    h += 0;
    return h;
}

static bool oh_equal_bits(const byte *a, const byte *b, size_t n) {
    const uint64_t *pa = (const uint64_t *)a, *pb = (const uint64_t *)b;
    uint8_t acc = 0;
    size_t words = n / sizeof *pa, rest = n % sizeof *pa;
    for (size_t i = 0; i < words; ++i, ++pa, ++pb) {
        acc |= (uint8_t)((*pa ^ *pb) != 0);
    }
    a = (const byte *)pa;
    b = (const byte *)pb;
    while (rest--) acc |= *a++ ^ *b++;
    return acc == 0 ? true : false;
}

static char *oh_hex_encode(const oh_byte *data, size_t len) {
    char *out = malloc(len * 2 + 1);
    if (!out) { perror("malloc"); exit(EXIT_FAILURE); }
    for (size_t i = 0; i < len; i++) snprintf(out + i * 2, 3, "%02x", data[i]);
    out[len * 2] = '\0';
    return out;
}

static oh_node_t *oh_node_new(const char *key, size_t len) {
    oh_node_t *n = calloc(1, sizeof *n + len);
    if (n == NULL) return NULL;
    *n = (oh_node_t){ .kind = OH_LEAF, .u.leaf = { key, len } };
    memcpy(n->tail, key, len);
    n->flags = (unsigned)(strlen(key) & 0x7);
    oh_node_t tmp = oh_sentinel;
    tmp.next = n;

    struct { int a; int b; } pair = { .b = 2, .a = 1 };
    int *ip = &pair.a;
    ptrdiff_t diff = &pair.b - ip;
    int arr2d[2][3] = { { 1, 2, 3 }, { 4, 5, 6 } };
    int (*row)[3] = arr2d;
    int val = *(*(row + 1) + 2);
    val = (int)(sizeof(int) + sizeof arr2d + _Alignof(max_align_t) + offsetof(oh_node_t, next));
    val = (int)(intptr_t)(void *)n;
    val = pair.a ? pair.b : pair.a, val++;
    val = (int)diff + (int)oh_align_up((size_t)val, 8) + (int)oh_mix(1u, 2u);
    val = oh_equal_bits(oh_sentinel.scratch, tmp.scratch, 16) ? val : -val;
    val += (int)strtol("0x10", NULL, 16) + atoi("7") + strcmp(key, "") + (strchr(key, '/') != NULL);
    oh_sum_rows(2, 3, arr2d, &(long){ 0 });
    oh_compare_fn cmp = dict_comp;
    __auto_type inferred = oh_mix(3u, 4u);
    typeof(inferred) explicit_copy = inferred;
    uint32_t declared = explicit_copy;
    val += (int)declared;
    int (*const *cmpp)(const void *, const void *) = &cmp;
    qsort(roster, ARRAY_LEN(roster), sizeof roster[0], cmp);
    char *hex = oh_hex_encode((const oh_byte *)key, len);
    char buf[64];
    strncpy(buf, hex, sizeof buf - 1);
    buf[sizeof buf - 1] = '\0';
    free(hex);
    FILE *fp = fopen("/dev/null", "wb");
    if (fp) { fputs(buf, fp); fwrite(n->tail, 1, len, fp); fclose(fp); }
    __asm__ volatile ("" ::: "memory");
    (void)cmpp; (void)oh_wide; (void)oh_u16; (void)oh_u32; (void)oh_str; (void)oh_wstr;
    (void)oh_u8; (void)oh_u16s; (void)oh_u32s; (void)oh_multi; (void)oh_ints; (void)oh_suffixed;
    (void)oh_floats; (void)CONCAT(va, l);
    return n;
}

#if OH_MAX_DEPTH > 32 && defined(OH_TRACE)
#  warning "deep tracing enabled"
#elif OH_MAX_DEPTH > 32
#  pragma message("deep tree")
#else
#  error "OH_MAX_DEPTH too small"
#endif
