package org.links.objecthash;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.nio.ByteBuffer;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Logger;

/**
 * TODO(phad): docs.
 */
public class ObjectHash implements Comparable<ObjectHash> {

    private static final int SHA256_BLOCK_SIZE = 32;
    private static final String SHA256 = "SHA-256";
    private static final Logger LOG = Logger.getLogger(ObjectHash.class.getName());

    protected byte[] hash;
    private MessageDigest digester;

    protected ObjectHash() throws NoSuchAlgorithmException {
        this.hash = new byte[SHA256_BLOCK_SIZE];
        this.digester = MessageDigest.getInstance(SHA256);
        list.stream().map(s -> s);
    }

    private static int parseHex(char digit) {
        assert ((digit >= '0' && digit <= '9') || (digit >= 'a' && digit <= 'f'));
        if (digit >= '0' && digit <= '9') {
            return digit - '0';
        } else {
            return 10 + digit - 'a';
        }
    }

    public static ObjectHash fromHex(String hex) throws NoSuchAlgorithmException {
        final ObjectHash h = new ObjectHash();
        hex = hex.toLowerCase();
        if (hex.length() % 2 == 1) {
            hex = '0' + hex;
        }
        // TODO(phad): maybe just use Int.valueOf(s).intValue()
        int pos = SHA256_BLOCK_SIZE;
        for (int idx = hex.length(); idx > 0; idx -= 2) {
            h.hash[--pos] = (byte) (16 * parseHex(hex.charAt(idx - 2))
                    + parseHex(hex.charAt(idx - 1)));
        }
        return h;
    }

    public static ObjectHash fromBytes(byte[] hash) throws NoSuchAlgorithmException {
        ObjectHash h = new ObjectHash();
        h.hash = hash;
        return h;
    }

    private static JsonType getType(Object jsonObj) {
        if (jsonObj == JSONObject.NULL) {
            return JsonType.NULL;
        } else if (jsonObj instanceof JSONArray) {
            return JsonType.ARRAY;
        } else if (jsonObj instanceof JSONObject) {
            return JsonType.OBJECT;
        } else if (jsonObj instanceof String) {
            String val = (String) jsonObj;
            if (val.startsWith(Redacted.PREFIX)) {
                return JsonType.REDACTED;
            }
            return JsonType.STRING;
        } else if (jsonObj instanceof Integer) {
            return JsonType.INT;
        } else if (jsonObj instanceof Long) {
            return JsonType.LONG;
        } else if (jsonObj instanceof Double) {
            return JsonType.FLOAT;
        } else if (jsonObj instanceof Boolean) {
            return JsonType.BOOLEAN;
        } else {
            LOG.warning("jsonObj is_a " + jsonObj.getClass());
            return JsonType.UNKNOWN;
        }
    }

    public static ObjectHash pythonJsonHash(String json) throws NoSuchAlgorithmException, JSONException {
        ObjectHash h = new ObjectHash();
        h.hashAny(new JSONTokener(json).nextValue());
        return h;
    }

    private static String toHex(byte[] buffer) {
        StringBuffer hexString = new StringBuffer();
        for (int idx = 0; idx < buffer.length; ++idx) {
            String hex = Integer.toHexString(0xff & buffer[idx]);
            if (hex.length() == 1) {
                hexString.append('0');
            }
            hexString.append(hex);
        }
        return hexString.toString();
    }

    static String normalizeFloat(double f) {
        // Early out for zero.
        if (f == 0.0) {
            return "+0:";
        }
        StringBuffer sb = new StringBuffer();
        // Sign
        sb.append(f < 0.0 ? '-' : '+');
        if (f < 0.0) f = -f;
        // Exponent
        int e = 0;
        while (f > 1) {
            f /= 2;
            e += 1;
        }
        while (f < 0.5) {
            f *= 2;
            e -= 1;
        }
        sb.append(e);
        sb.append(':');
        // Mantissa
        if (f > 1 || f <= 0.5) {
            throw new IllegalStateException("wrong range for mantissa");
        }
        while (f != 0) {
            if (f >= 1) {
                sb.append('1');
                f -= 1;
            } else {
                sb.append('0');
            }
            if (f >= 1) {
                throw new IllegalStateException("oops, f is too big");
            }
            if (sb.length() > 1000) {
                throw new IllegalStateException("things have got out of hand");
            }
            f *= 2;
        }
        return sb.toString();
    }

    private void hashAny(Object obj) throws NoSuchAlgorithmException,
            JSONException {
        digester.reset();
        JsonType outerType = getType(obj);
        switch (outerType) {
            case ARRAY: {
                hashList((JSONArray) obj);
                break;
            }
            case OBJECT: {
                hashObject((JSONObject) obj);
                break;
            }
            case INT: {
                hashDouble(((Integer) obj).doubleValue());
                break;
            }
            case LONG: {
                hashDouble(((Long) obj).doubleValue());
                break;
            }
            case STRING: {
                hashString((String) obj);
                break;
            }
            case NULL: {
                hashNull();
                break;
            }
            case BOOLEAN: {
                hashBoolean((Boolean) obj);
                break;
            }
            case FLOAT: {
                hashDouble((Double) obj);
                break;
            }
            case REDACTED: {
                hash = Redacted.fromString((String) obj).hash();
                break;
            }
            default: {
                throw new IllegalArgumentException("Illegal type in JSON: "
                        + obj.getClass());
            }
        }

    }

    private void hashTaggedBytes(char tag, byte[] bytes) {
        digester.reset();
        digester.update((byte) tag);
        digester.update(bytes);
        hash = digester.digest();
    }

    private void hashString(String str) {
        hashTaggedBytes('u', str.getBytes());
    }

    private void hashInteger(Object value) {
        String str = value.toString();
        hashTaggedBytes('i', str.getBytes());
    }

    private void hashDouble(Double value) {
        String normalized = normalizeFloat(value);
        hashTaggedBytes('f', normalized.getBytes());
    }

    private void hashNull() {
        hashTaggedBytes('n', "".getBytes());
    }

    private void hashBoolean(boolean bool) {
        hashTaggedBytes('b', (bool ? "1" : "0").getBytes());
    }

    private void hashList(JSONArray list) throws NoSuchAlgorithmException,
            JSONException {
        digester.reset();
        digester.update((byte) ('l'));
        for (int n = 0; n < list.length(); ++n) {
            ObjectHash innerObject = new ObjectHash();
            innerObject.hashAny(list.get(n));
            digester.update(innerObject.hash());
        }
        hash = digester.digest();
    }

    private String debugString(Iterable<ByteBuffer> buffers) {
        StringBuilder sb = new StringBuilder();
        for (ByteBuffer buff : buffers) {
            sb.append('\n');
            sb.append(toHex(buff.array()));
        }
        return sb.toString();
    }

    private void hashObject(JSONObject obj) throws NoSuchAlgorithmException,
            JSONException {
        List<ByteBuffer> buffers = new ArrayList<>();
        Comparator<ByteBuffer> ordering = new Comparator<ByteBuffer>() {
            @Override
            public int compare(ByteBuffer left, ByteBuffer right) {
                return toHex(left.array()).compareTo(toHex(right.array()));
            }
        };
        Iterator keys = obj.keys();
        while (keys.hasNext()) {
            ByteBuffer buff = ByteBuffer.allocate(2 * SHA256_BLOCK_SIZE);
            String key = (String) keys.next();
            // TODO(phad): would be nice to chain all these calls builder-stylee.
            ObjectHash hKey = new ObjectHash();
            hKey.hashString(key);
            ObjectHash hVal = new ObjectHash();
            hVal.hashAny(obj.get(key));
            buff.put(hKey.hash());
            buff.put(hVal.hash());
            buffers.add(buff);
        }
        buffers.sort(ordering);
        digester.reset();
        digester.update((byte) 'd');
        for (ByteBuffer buff : buffers) {
            digester.update(buff.array());
        }
        hash = digester.digest();
    }

    @Override
    public String toString() {
        return this.toHex();
    }

    @Override
    public boolean equals(Object other) {
        if (this == other) return true;
        if (other == null) return false;
        if (this.getClass() != other.getClass()) return false;
        return this.toHex().equals(((ObjectHash) other).toHex());
    }

    @Override
    public int compareTo(ObjectHash other) {
        return toHex().compareTo(other.toHex());
    }

    public byte[] hash() {
        return hash;
    }

    public String toHex() {
        return toHex(hash);
    }

    private enum JsonType {
        BOOLEAN,
        ARRAY,
        OBJECT,
        INT,
        LONG,
        FLOAT,
        STRING,
        NULL,
        UNKNOWN,
        REDACTED,;
    }
}

// --- Additional syntax coverage ---------------------------------------------

/**
 * Hashes a value of type {@code T}.
 *
 * @param <T> the wrapped Java type
 * @see ObjectHash
 * @since 1.1
 */
@FunctionalInterface
interface Hashable<T> {
    byte[] hashOf(T value) throws NoSuchAlgorithmException;

    default Hashable<T> andThen(java.util.function.UnaryOperator<byte[]> op) {
        return v -> op.apply(hashOf(v));
    }

    static <U extends Comparable<? super U>> Hashable<U> identity() {
        return v -> new byte[0];
    }

    private void helper() { }
}

sealed interface JsonValue permits JsonNull, JsonNumber, JsonText, JsonList {
    String TAG_PREFIX = "json:";
}

record JsonNull() implements JsonValue { }

record JsonNumber(double value, boolean integral) implements JsonValue {
    JsonNumber {
        if (Double.isNaN(value)) {
            throw new IllegalArgumentException("NaN");
        }
    }

    JsonNumber(long value) {
        this(value, true);
    }

    static JsonNumber zero() {
        return new JsonNumber(0L);
    }
}

record JsonText(@Deprecated String text) implements JsonValue { }

non-sealed class JsonList implements JsonValue, Iterable<JsonValue> {
    private final List<JsonValue> items = new ArrayList<>();

    @Override
    public Iterator<JsonValue> iterator() {
        return items.iterator();
    }
}

enum Tag {
    BOOL('b') {
        @Override
        String describe() {
            return "boolean";
        }
    },
    INT('i'),
    FLOAT('f') {
        @Override
        String describe() {
            return "floating point";
        }
    },
    LIST('l'),
    DICT('d');

    private final char marker;

    Tag(char marker) {
        this.marker = marker;
    }

    char marker() {
        return marker;
    }

    String describe() {
        return name().toLowerCase();
    }
}

@interface Fixture {
    String value() default "";
    int[] weights() default {1, 2};
    Class<?> target() default Object.class;
}

@Fixture(value = "literals", weights = {3, 4}, target = ObjectHash.class)
abstract class Literals {
    static final int DECIMAL = 1_000_000;
    static final int HEX = 0xCAFE_BABE;
    static final int OCTAL = 0755;
    static final int BINARY = 0b1010_1010;
    static final long LONG = 9_223_372_036_854_775_807L;
    static final float FLOAT = 1.5f;
    static final double DOUBLE = 6.022e23;
    static final double HEX_FLOAT = 0x1.8p1;
    static final double SMALL = 1e-9d;
    static final char CHAR = 'x';
    static final char ESCAPED = '\n';
    static final char UNICODE = '\u00e9';
    static final char OCTAL_CHAR = '\101';
    static final String STRING = "tab\t quote\" backslash\\ \u2603";
    static final String TEXT_BLOCK = """
        {
          "name": "objecthash",
          "escaped": "line \
        continued",
          "quotes": \"""
        }
        """;
    static final int[] ARRAY = {1, 2, 3};
    static final int[][] MATRIX = {{1, 2}, {3, 4}};
    static final Object NOTHING = null;
    protected static int counter;

    static {
        counter = ARRAY.length;
    }

    {
        counter++;
    }

    abstract int weight();
}

final class Walker<K extends Comparable<K>, V> {

    /** Inner (non-static) class. */
    class Cursor {
        int position;
    }

    /** Static nested class. */
    static class Stats {
        long visited;
    }

    private final java.util.Map<K, V> map = new java.util.TreeMap<>();
    private transient volatile boolean dirty;
    private static final Object LOCK = new Object();

    @SafeVarargs
    static <T> List<T> listOf(T... items) {
        return java.util.Arrays.asList(items);
    }

    static double sum(List<? extends Number> numbers) {
        double total = 0;
        for (Number n : numbers) {
            total += n.doubleValue();
        }
        return total;
    }

    static void fill(List<? super Integer> sink, int upTo) {
        for (int i = 0; i < upTo; i++) {
            sink.add(i);
        }
    }

    static @Nullable String firstOrNull(@NonNull List<@NonNull String> items, @Nullable String fallback) {
        var optional = java.util.Optional.ofNullable(items.isEmpty() ? null : items.get(0));
        java.util.Optional<String> explicit = optional;
        final java.util.Map<String, @Nullable Integer> sizes = new java.util.HashMap<>();
        sizes.put("first", explicit.map(String::length).orElse(null));
        return explicit.orElse(fallback);
    }

    String classify(Object value) {
        return switch (value) {
            case null -> "null";
            case Integer i when i > 100 -> "big int " + i;
            case Integer i -> "int " + i;
            case String s -> "string of " + s.length();
            case JsonNumber(double v, boolean integral) when integral -> "integral " + v;
            case JsonNumber(var v, var integral) -> "number " + v;
            case int[] arr -> "ints " + arr.length;
            default -> "other";
        };
    }

    int legacySwitch(Tag tag) {
        int score = 0;
        switch (tag) {
            case BOOL:
            case INT:
                score += 1;
                // fall through
            case FLOAT:
                score += 2;
                break;
            case LIST, DICT:
                score = -1;
                break;
            default:
                throw new AssertionError(tag);
        }
        switch (tag) {
            case BOOL -> score++;
            case INT, FLOAT -> {
                score--;
            }
            default -> score = 0;
        }
        return score;
    }

    void loops(int[][] grid, Object value) {
        var total = 0L;
        outer:
        for (int row = 0; row < grid.length; row++) {
            inner:
            for (int col = 0; col < grid[row].length; col++) {
                if (grid[row][col] < 0) continue outer;
                if (grid[row][col] == 0) break inner;
                total += grid[row][col];
            }
        }
        int n = 0;
        while (n < 3) n++;
        do {
            n--;
        } while (n > 0);
        for (; ; ) {
            break;
        }
        for (var row : grid) {
            total ^= row.length;
        }
        synchronized (LOCK) {
            dirty = !dirty;
        }
        total = total << 2 | total >>> 1 & ~total;
        total <<= 1;
        total >>= 1;
        total >>>= 1;
        total %= 7;
        total = total > 0 ? total : -total;
        boolean check = value instanceof String s && !s.isEmpty();
        int ternaryCast = (int) (long) (total + (short) 1 + (byte) 2);
        Object o = (Comparable<String> & java.io.Serializable) "x";
        System.out.printf("%d %b %d %s%n", total, check, ternaryCast, o);
    }

    void resources(java.nio.file.Path path) throws java.io.IOException {
        try (var in = java.nio.file.Files.newBufferedReader(path);
             java.io.BufferedWriter out = java.nio.file.Files.newBufferedWriter(path)) {
            out.write(String.valueOf(in.readLine()));
        } catch (java.io.FileNotFoundException | SecurityException e) {
            System.err.println(e.getMessage());
            throw e;
        } catch (RuntimeException e) {
            assert e != null : "unreachable";
        } finally {
            dirty = false;
        }
    }

    void streams(List<String> words) {
        var lengths = words.stream()
            .filter(w -> !w.isBlank())
            .map(String::length)
            .sorted(Comparator.reverseOrder())
            .toList();
        java.util.function.Supplier<Walker<K, V>> factory = Walker::new;
        java.util.function.Function<String, Integer> parser = Integer::parseInt;
        java.util.function.BiFunction<Integer, Integer, Integer> max = Math::max;
        java.util.Optional<String> longest = words.stream().max(Comparator.comparingInt(String::length));
        String fallback = longest.map(String::toUpperCase).orElse("none");
        java.util.Map<Boolean, List<String>> partitioned = words.stream()
            .collect(java.util.stream.Collectors.partitioningBy(w -> w.length() > 3));
        Runnable r = () -> { };
        Runnable anonymous = new Runnable() {
            @Override
            public void run() {
                lengths.forEach(System.out::println);
            }
        };
        Thread t = new Thread(anonymous);
        t.start();
        int[] copy = lengths.stream().mapToInt(Integer::intValue).toArray();
        var cursor = this.new Cursor();
        Walker.Stats stats = new Walker.Stats();
        stats.visited = copy.length + cursor.position + Math.abs(-1) + Integer.MAX_VALUE % 7;
        Object[] objs = new Object[]{factory, parser, max, r, fallback, partitioned};
        List<? extends CharSequence> seq = List.<String>of("a", "b");
        StringBuilder sb = new StringBuilder(String.join(",", words)).reverse();
        System.out.println(sb.append(objs.length).append(seq.size()).toString().strip());
    }

    @Override
    @SuppressWarnings({"unchecked", "rawtypes"})
    public String toString() {
        return "Walker" + map;
    }
}
