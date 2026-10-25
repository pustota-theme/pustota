import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math show Random, pi, cos, sin;
export 'package:flutter/widgets.dart' hide Table;

class ClickableMaskView extends StatelessWidget {
  const ClickableMaskView({
    Key? key,
    required this.rippleColor,
    required this.onClick,
    required this.padding,
    required this.radius,
  }) : super(key: key);

  final Color rippleColor;
  final Function onClick;
  final double padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.size!.height),
        child: Material(
          color: rippleColor,
          child: InkWell(
            onTap: () => onClick.call(),
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Additional syntax coverage
// ---------------------------------------------------------------------------

typedef JsonMap = Map<String, Object?>;
typedef Reducer<T> = T Function(T previous, T next);
typedef void LegacyCallback(int code);

/// Documentation comment for [Shape].
///
/// Supports `sealed` exhaustiveness in [describe].
sealed class Shape {
  const Shape();
  double get area;
}

final class Circle extends Shape {
  const Circle(this.radius);
  final double radius;
  @override
  double get area => math.pi * radius * radius;
}

final class Rect extends Shape {
  const Rect({required this.width, required this.height});
  final double width;
  final double height;
  @override
  double get area => width * height;
}

abstract interface class Describable {
  String describe();
}

base mixin Loggable {
  final List<String> _log = <String>[];
  void log(String message) => _log.add('[$runtimeType] $message');
}

mixin Scalable on Shape {
  Shape scaled(double factor);
}

enum Priority implements Comparable<Priority> {
  low(1, label: 'Low'),
  medium(5, label: 'Medium'),
  high(10, label: 'High');

  const Priority(this.weight, {required this.label});

  final int weight;
  final String label;

  static Priority parse(String raw) =>
      values.firstWhere((p) => p.label == raw, orElse: () => Priority.low);

  @override
  int compareTo(Priority other) => weight - other.weight;
}

extension StringX on String {
  String get capitalized => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  bool get isBlank => trim().isEmpty;
}

extension type const Meters(double value) implements double {
  Meters operator +(Meters other) => Meters(value + other.value);
}

@immutable
class Vector {
  const Vector(this.x, this.y);
  const Vector.zero() : x = 0, y = 0;
  factory Vector.fromJson(JsonMap json) =>
      Vector((json['x'] as num).toDouble(), (json['y'] as num?)?.toDouble() ?? 0);
  Vector.unit(double angle)
      : x = math.cos(angle),
        y = math.sin(angle);

  final double x;
  final double y;

  static const Vector origin = Vector.zero();

  Vector operator +(Vector o) => Vector(x + o.x, y + o.y);
  Vector operator -() => Vector(-x, -y);
  Vector operator *(double s) => Vector(x * s, y * s);
  double operator [](int i) => i == 0 ? x : y;
  @override
  bool operator ==(Object other) => other is Vector && other.x == x && other.y == y;
  @override
  int get hashCode => Object.hash(x, y);
  @override
  String toString() => 'Vector($x, $y)';
}

class Repository<K extends Comparable<K>, V extends Object> with Loggable implements Describable {
  Repository({Map<K, V>? seed, this.name = 'default'}) : _store = {...?seed};

  final Map<K, V> _store;
  final String name;
  late final int createdAt = DateTime.now().millisecondsSinceEpoch;
  int? _hits;
  static int instances = 0;

  V? operator [](K key) => _store[key];
  void operator []=(K key, V value) => _store[key] = value;

  V getOrPut(K key, V Function() ifAbsent) => _store.putIfAbsent(key, ifAbsent);

  Iterable<K> get keys sync* {
    for (final key in _store.keys) {
      yield key;
    }
    yield* _store.keys.where((k) => k.compareTo(k) == 0);
  }

  Stream<V> watch() async* {
    await for (final value in Stream<V>.fromIterable(_store.values)) {
      yield value;
    }
  }

  Future<V?> fetch(K key, {Duration timeout = const Duration(seconds: 1)}) async {
    try {
      final result = await Future<V?>.delayed(timeout, () => _store[key]);
      _hits = (_hits ?? 0) + 1;
      return result;
    } on TimeoutException catch (e, stack) {
      log('timeout: $e\n$stack');
      rethrow;
    } on StateError {
      return null;
    } catch (e) {
      throw StateError('unexpected: $e');
    } finally {
      log('fetch done');
    }
  }

  @override
  String describe() => '$name: ${_store.length} entries, hits=${_hits ?? 0}';
}

String describe(Shape shape) => switch (shape) {
      Circle(radius: final r) when r > 10 => 'big circle',
      Circle(:final radius) => 'circle $radius',
      Rect(width: var w, height: var h) when w == h => 'square $w',
      Rect() => 'rect',
    };

({double min, double max}) bounds(List<double> values) {
  var lo = double.infinity;
  var hi = double.negativeInfinity;
  for (final v in values) {
    if (v < lo) lo = v;
    if (v > hi) hi = v;
  }
  return (min: lo, max: hi);
}

(int, String) pair() => (1, 'one');

void literalsAndOperators([int? optional, String label = 'label']) {
  const int decimal = 1000000;
  const int hex = 0xDEADBEEF;
  const double exponent = 6.02e23;
  const double fraction = .5;
  const String raw = r'C:\path\$notInterpolated';
  const String single = 'it\'s';
  const String doubleQuoted = "say \"hi\" \u{1F600} \x41 \n";
  final String multi = """
    multi line
    with $decimal interpolation and ${hex.toRadixString(16)}
  """;
  const String rawMulti = r"""raw "triple" $noInterp""";
  final adjacent = 'one ' 'two ' "three";
  final list = <int>[1, 2, if (optional != null) optional, ...[3, 4], for (var i = 0; i < 2; i++) i];
  final set = <String>{'a', 'b', ...?null};
  final map = <String, dynamic>{'k': 1, if (hex > 0) 'hex': hex, ...{'z': 0}};
  final sym = #someSymbol;
  final (a, b) = pair();
  final (:min, :max) = bounds([1, 2, 3]);
  var [first, ...rest] = list;
  final {'k': k} = map;
  int? maybe;
  maybe ??= decimal;
  maybe = maybe! + 1;
  final length = label.isBlank ? 0 : label.capitalized.length;
  final bits = (hex & 0xFF) | (1 << 3) ^ ~0 >> 2 >>> 1;
  var counter = int.parse('7') + (int.tryParse('x') ?? 0) + num.parse('1.5').toInt();
  counter += 1;
  counter -= 1;
  counter *= 2;
  counter ~/= 2;
  counter %= 3;
  counter <<= 1;
  counter |= 1;
  counter &= 1;
  counter++;
  --counter;
  final ratio = decimal / 3;
  final truncated = decimal ~/ 3;
  final isShape = map is Map<String, dynamic> && map is! List;
  final asNum = (maybe as num).toInt();
  final ternary = counter > 0 ? 'pos' : 'non-pos';
  final cascade = StringBuffer()
    ..write(single)
    ..write(doubleQuoted)
    ..writeln(multi)
    ..writeAll([raw, rawMulti, adjacent], ', ');
  final repo = Repository<String, int>(seed: {'x': 1})
    ..['y'] = 2
    ..log('seeded')
    ..fetch('x').then((v) => print(v));
  final nested = Repository<String, Repository<String, int>>()..getOrPut('inner', () => repo);
  Repository<String, int>? maybeRepo = repo;
  maybeRepo?..describe();
  final fn = (int x, [int y = 1]) => x * y;
  int named({required int x, int y = 0}) => x + y;
  Reducer<int> reduce = (p, n) => p + n;
  LegacyCallback cb = (code) => print(code);
  final dynamic anything = fn(2, 3) + named(x: 1, y: 2) + reduce(1, 2);
  final sorted = [...list]..sort((x, y) => y.compareTo(x));
  final doubled = list.map((e) => e * 2).where((e) => e > 2).toList(growable: false);
  final total = list.fold<int>(0, (sum, e) => sum + e);
  final joined = set.join(', ').toUpperCase().padLeft(10, '*');
  final entries = map.entries.map((e) => '${e.key}=${e.value}').toSet();
  final lookup = Map<String, int>.fromIterables(['a', 'b'], [1, 2]);
  final unique = Set<int>.from(list)..addAll(sorted)..remove(0);
  late String lazy;
  lazy = '$a$b$k$first${rest.length}$min$max$sym$length$bits$ratio$truncated$isShape$asNum$ternary$anything';
  assert(lazy.isNotEmpty, 'must not be empty');
  outer:
  for (var i = 0; i < 3; i++) {
    for (final s in set) {
      if (s == 'a') continue outer;
      if (s == 'b') break outer;
    }
  }
  var n = 0;
  while (n < 3) {
    n++;
  }
  do {
    n--;
  } while (n > 0);
  switch (n) {
    case 0:
    case 1:
      print(cascade);
    case 2 when counter > 0:
      print(nested);
      break;
    case final other?:
      print(other);
    default:
      print(exponent + fraction);
  }
  cb(total + doubled.length + joined.length + entries.length + lookup.length + unique.length);
  print(lazy);
}

Future<void> main() async {
  final shapes = <Shape>[const Circle(1), const Rect(width: 2, height: 2)];
  for (final shape in shapes) {
    print(describe(shape));
  }
  await for (final v in Repository<String, int>(seed: {'a': 1}).watch()) {
    print(v);
  }
  final random = math.Random(42);
  final results = await Future.wait<int>([Future.value(1), Future.delayed(Duration.zero, () => 2)]);
  final completer = Completer<String>()..complete('done');
  final controller = StreamController<int>.broadcast();
  controller.stream.listen(print, onError: (Object e) => print(e), onDone: () => print(results));
  controller.add(random.nextInt(10));
  await controller.close();
  print(await completer.future);
  runZonedGuarded(() => literalsAndOperators(random.nextInt(10)), (error, stack) {});
}
