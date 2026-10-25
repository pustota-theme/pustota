using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Threading;
using static System.Console;

namespace AllFeaturesExample
{
    // Delegate definition
    public delegate void MyDelegate(string message);

    // Enum definition
    public enum MyEnum
    {
        None,
        First,
        Second
    }

    // Struct definition
    public struct MyStruct
    {
        public int Value;
        public MyStruct(int value)
        {
            Value = value;
        }
    }

    // Interface definition
    public interface IExample
    {
        void InterfaceMethod();
    }

    // Record type (immutable reference type)
    public record MyRecord(string Name, int Age);

    // Class implementing an interface
    public class ExampleClass : IExample
    {
        // Event using the delegate
        public event MyDelegate OnNotify;

        // Auto-implemented property with a default value
        private string PrivateAutoProperty { get; init; } = "Default";
        protected string ProtectedAutoProperty { get; init; } = "Default";
        public string AutoProperty { get; set; } = "Default";
        public string InitAutoProperty { get; init; } = "Default";

        // Expression-bodied property
        public int Length => AutoProperty.Length;

        // Indexer with a backing List<int>
        private List<int> _numbers = new List<int>();
        public int this[int index]
        {
            get => _numbers[index];
            set => _numbers[index] = value;
        }

        // Constructor
        public ExampleClass()
        {
            _numbers.AddRange(new[] { 1, 2, 3 });
        }

        // Interface method implementation
        public void InterfaceMethod()
        {
            WriteLine("InterfaceMethod invoked");
        }

        // Static method
        public static string StaticMethod(string input) => $"StaticMethod: {input}";

        // Operator overloading
        public static ExampleClass operator +(ExampleClass a, ExampleClass b)
        {
            var result = new ExampleClass();
            result._numbers.Clear();
            result._numbers.AddRange(a._numbers);
            result._numbers.AddRange(b._numbers);
            return result;
        }

        // Local function example
        public void LocalFunctionExample()
        {
            int LocalAdd(int x, int y) => x + y;
            WriteLine($"LocalAdd(2, 3) returns: {LocalAdd(2, 3)}");
        }

        // Pattern matching example
        public string PatternMatchExample(object obj)
        {
            return obj switch
            {
                null => "Object is null",
                int i => $"Object is an int: {i}",
                string s when s.Length > 5 => $"Long string: {s}",
                string s => $"Short string: {s}",
                _ => "Unknown type"
            };
        }

        // Discard usage in a deconstruction
        public void Deconstruct(MyRecord record)
        {
            var (name, _) = record;
            WriteLine($"Name is {name}, ignoring age");
        }

        // Enum usage
        public string EnumExample(MyEnum e)
        {
            return e switch
            {
                MyEnum.None => "None selected",
                MyEnum.First => "First selected",
                MyEnum.Second => "Second selected",
                _ => "Unrecognized"
            };
        }

        // Generic method
        public T GenericMethod<T>(T parameter)
        {
            WriteLine($"GenericMethod called with type {typeof(T)}");
            return parameter;
        }

        // Async/await example
        public async Task<string> AsyncMethod()
        {
            await Task.Delay(500);
            return "Async result";
        }
    }

    // Partial class demonstration (splitting the class into two files)
    public partial class PartialExample
    {
        public void PartialMethodOne()
        {
            WriteLine("PartialMethodOne in PartialExample");
        }
    }

    public partial class PartialExample
    {
        public void PartialMethodTwo()
        {
            WriteLine("PartialMethodTwo in PartialExample");
        }
    }

    // Record struct (immutable value type)
    public record struct MyRecordStruct(int X, int Y);

    // Main program
    public class Program
    {
        // Attribute usage
        [Obsolete("This method is obsolete, use Main instead.")]
        public static void OldMain() { }

        public static async Task Main(string[] args)
        {
            var example = new ExampleClass();

            // Event usage
            example.OnNotify += (msg) => WriteLine($"Event triggered: {msg}");
            example.OnNotify?.Invoke("Hello from event!");

            // Property usage
            example.AutoProperty = "Hello World";
            WriteLine($"AutoProperty: {example.AutoProperty}, Length: {example.Length}");

            // Indexer usage
            example[1] = 42;
            WriteLine($"Indexer[1]: {example[1]}");

            // Interface method call
            example.InterfaceMethod();

            // Static method call
            WriteLine(ExampleClass.StaticMethod("Example"));

            // Operator overloading
            var example2 = new ExampleClass();
            var combined = example + example2;
            WriteLine($"Combined object index 0: {combined[0]}, " +
                      $"index 1: {combined[1]}, " +
                      $"index 2: {combined[2]}, " +
                      $"index 3: {combined[3]}");

            // Local function usage
            example.LocalFunctionExample();

            // Pattern matching
            WriteLine(example.PatternMatchExample(null));
            WriteLine(example.PatternMatchExample(123));
            WriteLine(example.PatternMatchExample("Hi"));
            WriteLine(example.PatternMatchExample("Hello World"));

            // Discard usage
            example.Deconstruct(new MyRecord("Alice", 30));

            // Enum usage
            WriteLine(example.EnumExample(MyEnum.Second));

            // Generics
            example.GenericMethod("generic string");
            example.GenericMethod(99);

            // Async/await
            string asyncResult = await example.AsyncMethod();
            WriteLine($"Async result: {asyncResult}");

            // Partial class usage
            var partial = new PartialExample();
            partial.PartialMethodOne();
            partial.PartialMethodTwo();

            // Record usage
            var rec = new MyRecord("Bob", 25);
            WriteLine($"Record: {rec}");

            // Record struct usage
            var recordStruct = new MyRecordStruct(10, 20);
            MyRecordStruct recordStruct2 = new(10, 20);
            WriteLine($"Record struct: X={recordStruct.X}, Y={recordStruct.Y}");

            // LINQ usage
            List<int> numbers = new() { 1, 2, 3, 4, 5 };
            var oddSquares = numbers
                .Where(n => n % 2 != 0)
                .Select(n => n * n);
            WriteLine($"Odd squares: {string.Join(", ", oddSquares)}");

            // Raw string literal (C# 11+)
            string rawString = """
                This is a raw string literal
                that preserves whitespace and
                doesn't require escaping "quotes"
                or backslashes.
            """;
            WriteLine(rawString);

            // Reflection example
            var type = example.GetType();
            WriteLine($"Reflection: Class name is {type.Name} in namespace {type.Namespace}");

            // Environment info
            WriteLine($".NET version: {Environment.Version}");
        }
    }
}

#nullable enable
#pragma warning disable CS0168, CS8632

namespace AllFeaturesExample.Extras
{
    using System.Runtime.CompilerServices;
    using System.Runtime.InteropServices;
    using System.Text;
    using Lookup = System.Collections.Generic.Dictionary<string, int>;

    #region Literals and comments

    /// <summary>
    /// Holds every literal form the lexer knows about.
    /// </summary>
    /// <remarks>See <see cref="Program"/> and <paramref name="nothing"/> for usage.</remarks>
    internal static class Literals
    {
        public const int Decimal = 1_000_000;
        public const int Hex = 0x7F_EC_DE_5E;
        public const int Binary = 0b1010_0101;
        public const long Long = 9_223_372_036_854_775_807L;
        public const ulong ULong = 18_446_744_073_709_551_615UL;
        public const uint UInt = 4_294_967_295u;
        public const float Float = 1.5f;
        public const double Double = 6.022e23;
        public const double Negative = -1.5E-10d;
        public const decimal Money = 19.99m;
        public const char Char = 'A';
        public const char Escaped = '\n';
        public const char Unicode = '\u00E9';
        public const char HexChar = '\x41';
        public const string Verbatim = @"C:\Users\pustota\""quoted""";
        public const string Escapes = "tab\there\r\nnull\0 unicode\U0001F600 \"quotes\"";
        public static readonly string Interpolated = $"{Decimal:N0} and {Double:E2} and {{braces}} and {(Flag ? "yes" : "no")}";
        public static readonly string VerbatimInterpolated = $@"path\to\{Char}";
        public static readonly string InterpolatedVerbatim = @$"path\to\{Char}";
        public static readonly string Multiline = @"
            line one
            line two";
        public static readonly object? Nothing = null;
        public static readonly bool Flag = true || false;
        public static readonly int[] Numbers = { 1, 2, 3 };
        public static readonly int[,] Matrix = { { 1, 2 }, { 3, 4 } };
        public static readonly int[][] Jagged = { new[] { 1 }, new[] { 2, 3 } };
        public static readonly Lookup Table = new() { ["one"] = 1, ["two"] = 2 };
        public static readonly List<string> Names = new List<string> { "a", "b" };
        public static readonly (int X, int Y) Origin = (0, 0);
        public static readonly int[] Collection = [1, 2, .. Numbers, 4];
        public static ReadOnlySpan<byte> Utf8 => "bytes"u8;
    }

    #endregion

    /* A block comment
       spanning several lines */

    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Struct, AllowMultiple = true, Inherited = false)]
    public sealed class TrackedAttribute : Attribute
    {
        public TrackedAttribute(string owner) => Owner = owner;
        public string Owner { get; }
        public int Priority { get; set; }
    }

    public interface IShape
    {
        double Area { get; }
        string Describe() => $"{GetType().Name} with area {Area:F2}";
        static abstract IShape Unit { get; }
    }

    public abstract class Shape : IShape
    {
        public abstract double Area { get; }
        public virtual string Describe() => $"shape {Math.Round(Area, 2)}";
        public static IShape Unit => new Circle(1);
        protected Shape() { }
        ~Shape() { }
    }

    [Tracked("geometry", Priority = 1)]
    public sealed class Circle : Shape, IEquatable<Circle>
    {
        public Circle(double radius) => Radius = radius;
        public double Radius { get; }
        public override double Area => Math.PI * Math.Pow(Radius, 2);
        public override string Describe() => base.Describe() + " (circle)";
        public bool Equals(Circle? other) => other is not null && Math.Abs(other.Radius - Radius) < double.Epsilon;
        public override bool Equals(object? obj) => obj is Circle c && Equals(c);
        public override int GetHashCode() => HashCode.Combine(Radius);
        public static bool operator ==(Circle? a, Circle? b) => a?.Radius == b?.Radius;
        public static bool operator !=(Circle? a, Circle? b) => !(a == b);
        public static implicit operator double(Circle c) => c.Radius;
        public static explicit operator Circle(double r) => new(r);
        public void Deconstruct(out double radius, out double area) => (radius, area) = (Radius, Area);
    }

    public readonly record struct Point(double X, double Y)
    {
        public static Point Zero => new(0, 0);
        public double Distance(Point other) => Math.Sqrt(Math.Pow(X - other.X, 2) + Math.Pow(Y - other.Y, 2));
    }

    public record Rectangle(Point TopLeft, Point BottomRight) : IShape
    {
        public double Area => Math.Abs(BottomRight.X - TopLeft.X) * Math.Abs(BottomRight.Y - TopLeft.Y);
        public required string Label { get; init; }
        public Rectangle Grow(double by) => this with { BottomRight = new Point(BottomRight.X + by, BottomRight.Y + by) };
        public static IShape Unit => new Rectangle(Point.Zero, new Point(1, 1)) { Label = "unit" };
    }

    public class Inventory(string name, int capacity)
    {
        public string Name { get; } = name;
        public int Capacity => capacity;
    }

    public class Repository<TKey, TValue>
        where TKey : notnull, IComparable<TKey>
        where TValue : class, new()
    {
        private readonly SortedDictionary<TKey, TValue> _store = new();
        public event EventHandler<TKey>? Added;

        public TValue this[TKey key]
        {
            get => _store.TryGetValue(key, out var value) ? value : new TValue();
            set { _store[key] = value; Added?.Invoke(this, key); }
        }

        public IEnumerable<TValue> Values()
        {
            foreach (var (_, value) in _store)
            {
                yield return value;
            }
            yield break;
        }

        public async IAsyncEnumerable<TKey> KeysAsync([EnumeratorCancellation] CancellationToken token = default)
        {
            foreach (TKey key in _store.Keys)
            {
                await Task.Yield();
                if (token.IsCancellationRequested) yield break;
                yield return key;
            }
        }
    }

    public static class Extensions
    {
        public static int WordCount(this string text) => text.Split(' ', StringSplitOptions.RemoveEmptyEntries).Length;
        public static T? FirstOrNull<T>(this IEnumerable<T> source) where T : struct => source.Any() ? source.First() : null;
        public static void Swap<T>(ref T a, ref T b) => (a, b) = (b, a);
        public static bool TryParse(this string s, out int value) => int.TryParse(s, out value);
        public static ref int Ref(this int[] arr, in int i) => ref arr[i];
    }

    public enum Status : byte
    {
        Idle = 0,
        Running = 1 << 1,
        Done = Running | 0x4,
    }

    [Flags]
    public enum Permissions : uint { None = 0, Read = 1, Write = 2, Execute = 4, All = Read | Write | Execute }

    public static class Demo
    {
        private static unsafe void UnsafeDemo()
        {
            int local = 5;
            int* p = &local;
            *p += 1;
            Span<byte> buffer = stackalloc byte[16];
            byte* raw = stackalloc byte[8];
            int[] arr = { 1, 2, 3 };
            fixed (int* ap = arr)
            {
                ap[1] = *(ap + 2);
            }
            delegate* unmanaged<int, int> fp = null;
            delegate*<int, int> managed = &Twice;
            int sz = sizeof(long) + buffer.Length + (raw == null ? 0 : 1) + (fp == null ? 0 : 1) + managed(2);
        }

        private static int Twice(int x) => x * 2;

        public static string Classify(object? o) => o switch
        {
            int and > 0 and < 10 => "small int",
            int or long => "integer",
            string { Length: > 3 } s => $"long string {s.ToUpperInvariant()}",
            Point(0, 0) => "origin",
            Point { X: var x, Y: var y } when x == y => "diagonal",
            Circle c => c.Describe(),
            int[] [] => "empty list",
            int[] [1, ..] => "list starting with one",
            null => "null",
            not null => "something",
        };

        public static void ControlFlow(IEnumerable<int> values)
        {
            int i = 0;
            while (i < 3) i++;
            do { i--; } while (i > 0);
            for (int j = 0, k = 10; j < k; j++, k--) { if (j == 2) continue; if (k == 5) break; }
            foreach (int v in values.ToArray().AsSpan()) { }

        outer:
            foreach (var v in values)
            {
                switch (v)
                {
                    case 0:
                    case 1:
                        goto case 2;
                    case 2:
                        break;
                    case int n when n < 0:
                        goto outer;
                    default:
                        goto end;
                }
            }
        end:
            try
            {
                checked { int overflow = int.MaxValue; overflow++; }
                unchecked { int wrap = int.MaxValue + 1; }
                throw new InvalidOperationException("boom");
            }
            catch (InvalidOperationException ex) when (ex.Message.Contains("boom"))
            {
                Console.Error.WriteLine(ex);
                throw;
            }
            catch
            {
            }
            finally
            {
                Console.WriteLine(nameof(ControlFlow));
            }

            using (var reader = new System.IO.StringReader("text"))
            {
                _ = reader.ReadLine();
            }
            using var disposable = new System.IO.StringReader("more");
            lock (disposable) { }

            object? maybe = null;
            string text = maybe?.ToString() ?? "fallback";
            maybe ??= text;
            int? nullable = maybe as int?;
            int length = (maybe as string)?.Length ?? -1;
            bool isNum = maybe is int;
            int casted = (int)3.7;
            Type t = typeof(List<>);
            string name = nameof(Literals.Decimal);
            int bits = (0b1100 & 0b1010) | (1 << 3) ^ ~0 >> 2;
            bits <<= 1; bits >>= 1; bits |= 1; bits &= ~1; bits ^= 0xF; bits %= 7; bits *= 2; bits /= 2;
            var ternary = bits > 0 ? "pos" : "non-pos";
            Index last = ^1;
            Range middle = 1..^1;
            int[] slice = Literals.Numbers[middle];
            int lastItem = Literals.Numbers[last];
            var tuple = (Name: "x", Value: 1);
            var (nm, val) = tuple;
            (int a, int b) = (1, 2);
            Func<int, int, int> add = (x, y) => x + y;
            Func<int, int> square = static x => x * x;
            Action<string> log = delegate (string s) { Console.WriteLine(s); };
            Predicate<int> isEven = n => n % 2 == 0;
            var lambdaWithType = (int x, string? y = null) => $"{x}{y}";
            int Local(int x, params int[] rest) => x + rest.Sum();
            static int StaticLocal(int x) => Math.Max(x, 0) * 2;
            var sb = new StringBuilder().Append(text).AppendLine(ternary);
            string joined = string.Join(", ", Literals.Names.Select(n => n.PadLeft(3)));
            double parsed = double.Parse("3.5") + Convert.ToDouble("1") + Math.Floor(2.7) + int.Parse("4");
            Dictionary<string, List<int>> grouped = new();
            grouped.TryAdd("key", new List<int> { 1 });
            Console.WriteLine($"{sb} {joined} {parsed} {grouped.Count} {DateTime.UtcNow:O} {Guid.NewGuid()}");
            log(Local(1, 2, 3) + StaticLocal(2) + add(1, 2) + square(3) + " done");
            Named(count: 3, label: "x");
            dynamic dyn = 1;
            dyn += 1;
            var anon = new { Name = "anon", Age = 3 };
            var query = from n in values
                        where n > 0
                        let sq = n * n
                        orderby sq descending, n
                        group sq by n % 2 into g
                        select new { Key = g.Key, Items = g.ToList() };
            var joinedQuery = from x in values
                              join y in values on x equals y
                              select x + y;
            _ = query.Count() + joinedQuery.Count() + anon.Age + (int)dyn + length + casted + lastItem + slice.Length
                + nullable.GetValueOrDefault() + (isNum ? 1 : 0) + (t == null ? 0 : 1) + name.Length + a + b
                + nm.Length + val + (isEven(2) ? 1 : 0) + lambdaWithType(1).Length;
        }

        public static void Named(int count, string label = "default", params object[] extra) { }

        public static async Task<int> AsyncWork(CancellationToken ct = default)
        {
            await using var stream = new System.IO.MemoryStream();
            var tasks = new[] { Task.FromResult(1), Task.Run(() => 2, ct) };
            int[] results = await Task.WhenAll(tasks).ConfigureAwait(false);
            await foreach (var key in new Repository<int, object>().KeysAsync(ct))
            {
                results[0] += key;
            }
            await Task.Delay(TimeSpan.FromMilliseconds(1), ct);
            return results.Sum();
        }
    }

    public struct Vector2 : IEquatable<Vector2>
    {
        public float X, Y;
        public Vector2(float x, float y) { X = x; Y = y; }
        public static Vector2 operator +(Vector2 a, Vector2 b) => new(a.X + b.X, a.Y + b.Y);
        public static Vector2 operator -(Vector2 a) => new(-a.X, -a.Y);
        public static Vector2 operator *(Vector2 a, float s) => new(a.X * s, a.Y * s);
        public static bool operator true(Vector2 v) => v.X != 0 || v.Y != 0;
        public static bool operator false(Vector2 v) => v.X == 0 && v.Y == 0;
        public bool Equals(Vector2 other) => X == other.X && Y == other.Y;
        public readonly override string ToString() => $"({X}, {Y})";
    }

    public ref struct StackOnly
    {
        public Span<int> Data;
        public StackOnly(Span<int> data) => Data = data;
    }

#if DEBUG
    internal static class DebugOnly { }
#elif RELEASE
    internal static class ReleaseOnly { }
#else
    internal static class Neither { }
#endif

    public class Outer
    {
        public class Nested { public int Depth = 1; }
        private protected int Hidden;
        internal event Action? Changed;
        public static Outer operator ++(Outer o) { o.Hidden++; o.Changed?.Invoke(); return o; }

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool Beep(uint frequency, uint duration);

        [Obsolete, STAThread]
        public static void Entry() { }

        [return: MaybeNull]
        public string? Maybe([NotNullWhen(true)] string? input) => input;
    }
}

#nullable restore
#pragma warning restore CS0168, CS8632
