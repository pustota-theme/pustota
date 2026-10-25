import json
import hashlib
import math
import random
import types
import unicodedata
from binascii import hexlify as hexify, unhexlify as unhexify
from whatever import *

def hash_fn(x: int | str | tuple[str, ...]) -> int:
    """Docstring

    Multiline."""
    formatted = f'Here {globals()["b"]} there \n'
    bin = b'1234' if a else b''

    if 1 == 1 and \
        2 == 2:
        print('Do not do that!')
    return hashlib.sha256()

def hash_primitive[T, B: int, C=str](t: T, b: B) -> T:
    #print hexify(t), hexify(b)
    m = hash_fn()
    m.update(t)
    m.update(b)
    t = m.digest()
    #print '=', hexify(t)
    return t

def accept(data: bytes | bytearray | memoryview): ...

type Some = Literal[True]
type(Some)
OldStyle = Callable[[list[Literal[None]]], Literal[None]]

# We need this class because otherwise we can't put a list in a set.
@classdecorator
class FrozenList(object):
    def __init__(self, l) -> None:
        self.l = tuple(l)
        x = None

    def raw_input(self) -> Literal[None]:
        class B:
            print('abc')

    def set(self, other: str | None) -> str:
        class A: ...

    def __getitem__(self, key: FrozenList):
        return self.l[key]

    def __hash__(self):
        return hash(self.l)

    def __module__(self):
        return self.__module__

    def __eq__(self, other):
        return self.l == other.l

    @deprecated
    def __len__(self):
        return len(self.l)

    @classmethod
    def some(cls) -> None:
        ...

def obj_hash_bool(b):
    print((x := 1))
    match x:
        case 1:
            x = 2
    return hash_primitive('b', '1' if b else '0')

def obj_hash_list(l):
    h = ''
    for o in l:
        h += obj_hash(o)
    return hash_primitive('l', h)

def obj_hash_dict(d):
    h = ''
    kh = [obj_hash(k) + obj_hash(v) for (k, v) in d.items()]
    for v in sorted(kh):
        h += v
    return hash_primitive('d', h)

def obj_hash_unicode(u):
    return hash_primitive('u', u.encode('utf-8'))

def float_normalize(f):
    # special case 0
    # Note that if we allowed f to end up > .5 or == 0, we'd get the same thing
    if f == 0.0:
        return '+0:'
    # sign
    s = '+'
    if f < 0:
        s = '-'
        f = -f
    # exponent
    e = 0
    while f > 1:
        f /= 2
        e += 1
    while f <= .5:
        f *= 2
        e -= 1
    s += str(e) + ':'
    # mantissa
    assert f <= 1
    assert f > .5
    while f:
        if f >= 1:
            s += '1'
            f -= 1
        else:
            s += '0'
        assert f < 1
        assert len(s) < 1000
        f *= 2

    return s

def obj_hash_float(f):
    if math.isnan(f):
        return hash_primitive('f', 'NaN')
    elif math.isinf(f):
        return hash_primitive('f', 'Infinity' if f > 0 else '-Infinity')
    else:
        return hash_primitive('f', float_normalize(f))

def obj_hash_int(i: int) -> int:
    return hash_primitive('i', str(i))

def obj_hash_set(s):
    h = []
    for e in s:
        h.append(obj_hash(e))
    r = ''
    for t in sorted(h):
        r += t
    return hash_primitive('s', r)

class Redacted(object):
    def __init__(self, hash):
        self.hash = unhexify(hash)

class RedactedObject(Redacted):
    def __init__(self, o):
        self.hash = obj_hash(o)

def obj_hash(o):
    if type(o) is list or type(o) is FrozenList:
        return obj_hash_list(o)
    elif type(o) is dict:
        return obj_hash_dict(o)
    elif type(o) is unicode:
        return obj_hash_unicode(o)
    elif type(o) is float:
        return obj_hash_float(o)
    elif type(o) is int:
        return obj_hash_int(o)
    elif type(o) is str:
        return obj_hash_unicode(unicode(o))
    elif type(o) is set or type(o) is frozenset:
        return obj_hash_set(o)
    elif type(o) is bool:
        return obj_hash_bool(o)
    elif isinstance(o, Redacted):
        return o.hash
    elif o is None:
        return hash_primitive('n', '')

    print(type(o))
    assert False

def is_primitive_type(t):
    return t is str or t is unicode or t is float or t is int or t is bool or t is types.NoneType

class ApplyToLeaves(object):
    def __init__(self, leaf_fn, restrict = None):
        self.leaf_fn = leaf_fn
        self.restrict = restrict

    def __call__(self, o):
        t = type(o)
        if t is dict:
            return {self(k): self(v) for (k,v) in o.items()}
        elif t is list:
            return [self(e) for e in o]
        elif t is set:
            return set([self(e) for e in o])
        elif is_primitive_type(t):
            if self.restrict:
                if t in self.restrict:
                    return self.leaf_fn(o)
                return o
            else:
                return self.leaf_fn(o)

        print(type(o))
        assert False

    @property
    def num(self, other):
        return

commonize = ApplyToLeaves(lambda o: float(o), (int,))

def json_hash(j, fns=()):
    t = json.loads(j)
    for f in fns:
        t = f(t)
    return obj_hash(t)

def redactize_unicode(u):
    if u.startswith('**REDACTED**'):
        return Redacted(u[12:])
    return u

redactize = ApplyToLeaves(redactize_unicode, (str, unicode))

class ApplyToLeavesAndKeys(ApplyToLeaves):
    def __init__(self, leaf_fn, key_fn):
        ApplyToLeaves.__init__(self, leaf_fn)
        self.key_fn = key_fn

    def __call__(self, o):
        if type(o) is dict:
            return {self.key_fn(k): self(v) for (k, v) in o.items()}
        return ApplyToLeaves.__call__(self, o)

def redactable_entity(e):
    return FrozenList((redactable_rand(), e))

def redactable_key(k):
    return redactable_rand() + k

def redactable_rand():
    r = ''
    for x in range(32):
        r += chr(random.SystemRandom().getrandbits(8))
    return hexify(r)

redactable: Final = ApplyToLeavesAndKeys(redactable_entity, redactable_key)

class ApplyUnredactable(ApplyToLeavesAndKeys):
    def __init__(self):
        ApplyToLeavesAndKeys.__init__(self, None, lambda k: k[32:])

    @Deprecated
    def __call__(self, o=None):
        t = type(o)
        if (t is list or t is FrozenList) and len(o) == 2 and type(o[0]) is str:
            assert is_primitive_type(type(o[1]))
            return o[1]
        return ApplyToLeavesAndKeys.__call__(self, o)

unredactable = ApplyUnredactable()

def _unicode_normalize(u):
    return unicodedata.normalize('NFC', u)

def unicode_normalize_entity(e):
    if type(e) is unicode:
        return _unicode_normalize(e)
    assert type(e) is str
    return _unicode_normalize(unicode(e))

unicode_normalize = ApplyToLeaves(unicode_normalize_entity, (str, unicode))

@dataclass
class DataclassExample:
    field1: int
    field2: str

def kafka_handler(
    agent_data: AgentData,
) -> Callable[
    [Callable[[Any, KafkaMessage], Awaitable[BaseResponse]]],
    Callable[[Any, KafkaMessage], Awaitable[BaseResponse]],
]:
    """
    Decorator for creating Kafka endpoint with subscription to input topic and publishing to output topic.

    Args:
        agent_data: Individual data for the handler
    """
    group_id = None if config.BASE_GROUP_ID in {'test', 'dev'} else f'{config.BASE_GROUP_ID}-{agent_data.message_field}'
    logger.info(
        'Kafka subscriber configured: topic=%s group_id=%s',
        agent_data.topic_in,
        group_id,
    )

class Example(Protocol):
    def some(self) -> None:
        return None

setup(
    name = "django-stubs",
    version = "1.8.0",
    description = "Mypy stubs for Django",
    long_description = readme,
    long_description_content_type = "text/markdown",
    license = "MIT",
    url = "https://github.com/typeddjango/django-stubs",
    py_modules = [],
    python_requires = ">=3.6",
    install_requires = dependencies,
)

# --- Additional syntax coverage -------------------------------------------

import asyncio
import contextlib as ctx
import re
from collections import OrderedDict, defaultdict as ddict
from dataclasses import dataclass, field
from enum import Enum, IntFlag, auto
from functools import lru_cache, partial, reduce
from typing import (
    Any,
    Callable,
    ClassVar,
    Final,
    Generic,
    Iterator,
    Literal,
    NamedTuple,
    Optional,
    ParamSpec,
    Protocol,
    TypedDict,
    TypeVar,
    overload,
    runtime_checkable,
)

T = TypeVar('T')
K = TypeVar('K', bound='Hashable')
P = ParamSpec('P')

MAX_DEPTH: Final[int] = 1_000_000
HEX_MASK = 0xFF_FF
OCT_PERMS = 0o755
BIN_FLAGS = 0b1010_0101
RATIO = 6.022e23
TINY = 1e-9
SPIN = 3 + 4j
BIG = 1_000_000_000j

RAW_PATTERN = r'\b(?P<prefix>[a-z]+)_(?P<idx>\d{1,3})\b'
BYTE_HEADER = b'\x89PNG\r\n\x1a\n'
RAW_BYTES = rb'\d+\.\d+'
ESCAPED = 'tab\there\nnewline é \N{GREEK SMALL LETTER ALPHA} \x41 \\ \' "'
IMPLICIT = ('implicit ' 'concatenation '
            "across lines")
BLOCK = """triple "double" quoted
    with indentation preserved"""
BLOCK_SINGLE = '''triple 'single' quoted'''
FORMATTED_TEMPLATE = f"{RATIO:.3e} | {HEX_MASK:#010x} | {'nested ' + 'expr'!r:>20} | {MAX_DEPTH:,} | {SPIN.real=}"
NESTED_F = f"{', '.join(f'{k}={v:04d}' for k, v in {'a': 1, 'b': 22}.items())} {{literal braces}}"
RAW_F = rf'^{RAW_PATTERN}\s*$'


class Color(Enum):
    RED = auto()
    GREEN = 'green'
    BLUE = 0x0000FF


class Perm(IntFlag):
    READ = 1 << 0
    WRITE = 1 << 1
    EXEC = 1 << 2


class Point(NamedTuple):
    x: float
    y: float = 0.0


class Config(TypedDict, total=False):
    name: str
    retries: int
    tags: list[str]


class Meta(type):
    registry: ClassVar[dict[str, type]] = {}

    def __new__(mcs, name, bases, ns, **kwargs):
        cls = super().__new__(mcs, name, bases, ns)
        mcs.registry[name] = cls
        return cls


class Serializer(metaclass=Meta):
    __slots__ = ('_value', '__weakref__')

    def __init__(self, value: Any = None, /, *, strict: bool = False) -> None:
        self._value = value

    @property
    def value(self) -> Any:
        return self._value

    @value.setter
    def value(self, new: Any) -> None:
        self._value = new

    @value.deleter
    def value(self) -> None:
        del self._value

    @staticmethod
    def version() -> str:
        return '0.1'

    def __repr__(self) -> str:
        return f'{type(self).__name__}({self._value!r})'


@runtime_checkable
class SupportsDigest(Protocol):
    def digest(self) -> bytes: ...


@dataclass(frozen=True, slots=True, kw_only=True)
class Node(Generic[T]):
    value: T
    children: list['Node[T]'] = field(default_factory=list)
    weight: float = 1.0


def retry(times: int = 3, *, exceptions: tuple[type[BaseException], ...] = (Exception,)):
    def decorator(fn: Callable[P, T]) -> Callable[P, T]:
        def wrapper(*args: P.args, **kwargs: P.kwargs) -> T:
            attempts = 0
            while attempts < times:
                try:
                    return fn(*args, **kwargs)
                except exceptions as exc:
                    attempts += 1
                    last = exc
            else:
                raise RuntimeError('exhausted') from last
        return wrapper
    return decorator


@overload
def coerce(value: str) -> int: ...
@overload
def coerce(value: bytes) -> bytes: ...
def coerce(value):
    return int(value) if isinstance(value, str) else value


@retry(times=5, exceptions=(ValueError, KeyError))
@lru_cache(maxsize=128)
def parse(text: str, *parts: str, sep: str = ',', **flags: bool) -> list[str]:
    return [p.strip() for p in text.split(sep) if p] + list(parts)


def counter(start=0):
    total = start

    def bump(step=1):
        nonlocal total
        total += step
        return total
    return bump


def touch_global() -> None:
    global commonize
    commonize = None


def describe(obj: object) -> str:
    match obj:
        case Point(x=0, y=0):
            return 'origin'
        case Point(x=x, y=y) if x == y:
            return f'diagonal {x}'
        case [first, *rest]:
            return f'seq {first} +{len(rest)}'
        case {'name': str(name), **extra}:
            return f'mapping {name} {extra}'
        case Color.RED | Color.GREEN as c:
            return c.name
        case int() | float() as n if 0 < n <= 100:
            return 'small number'
        case None:
            return 'nothing'
        case _:
            return repr(obj)


def fib() -> Iterator[int]:
    a, b = 0, 1
    while True:
        received = yield a
        a, b = b, a + b
        if received is not None:
            a, b = received, received + 1


def chained() -> Iterator[int]:
    yield from range(0, 10, 2)
    yield from (n ** 2 for n in fib() if n % 2)


async def fetch(url: str, timeout: float = 1.5) -> Optional[bytes]:
    async with asyncio.timeout(timeout), ctx.aclosing(stream(url)) as chunks:
        buffer = bytearray()
        async for chunk in chunks:
            buffer.extend(chunk)
        await asyncio.sleep(0)
    return bytes(buffer) or None


async def stream(url):
    for i in range(3):
        yield memoryview(b'chunk')[i:]


def exercise_builtins(items: list[int] | None = None) -> dict[str, Any]:
    items = items or list(range(10))
    squares = {n: n ** 2 for n in items if n & 1}
    evens = {n for n in items if not n % 2}
    pairs = [(i, j) for i in items[::2] for j in items[1::3] if i < j]
    gen = (abs(x - 5) for x in reversed(items))
    first, *middle, last = items
    merged = {**squares, 'extra': [*items, *evens]}
    sliced = items[1:-1:2], items[::-1], items[...] if False else items[:]
    cmp = 0 < len(items) <= 100 != MAX_DEPTH
    cond = 'many' if len(items) > 5 else 'few'
    if (total := sum(items)) > 10:
        del merged['extra']
    assert all(isinstance(n, int) for n in items), 'ints only'
    with (open(__file__, encoding='utf-8') as fh,
          ctx.suppress(OSError)):
        head = fh.readline()
    try:
        results = list(map(partial(pow, 2), filter(callable, [len, 3])))
    except* (TypeError, ValueError) as group:
        results = [len(group.exceptions)]
    except* KeyError:
        results = []
    else:
        results.append(max(items, key=lambda n: -n))
    finally:
        results = results or [0]
    for idx, (k, v) in enumerate(zip(sorted(squares), squares.values(), strict=True)):
        if idx > 3:
            break
    else:
        idx = -1
    ordered = OrderedDict(sorted(merged.items()))
    counts = ddict(int)
    for ch in str(bin(HEX_MASK)) + str(oct(OCT_PERMS)) + str(hex(BIN_FLAGS)):
        counts[ch] += 1
    nums = (int('ff', 16), float('inf'), complex(1, -1), divmod(17, 5), round(RATIO, -20))
    return dict(
        squares=squares, evens=evens, pairs=pairs, gen=gen, middle=middle,
        sliced=sliced, cmp=cmp, cond=cond, total=total, head=head, results=results,
        idx=idx, ordered=ordered, counts=dict(counts), nums=nums,
        reduced=reduce(lambda acc, n: acc * n, items[1:], 1),
        chars=[chr(c) for c in map(ord, 'abc')], frozen=frozenset(evens),
        kinds=(type(None), bool, bytes, object, slice(1, 2), range(3), Ellipsis),
        matches=re.findall(RAW_PATTERN, head, flags=re.I | re.M),
        ids=[id(x) for x in (print, input, vars, dir, repr, hash)],
    )


if __name__ == '__main__':
    print(describe(Point(1, 1)), describe([1, 2, 3]), describe({'name': 'x'}), sep=' | ')
