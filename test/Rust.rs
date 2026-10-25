// NOTE: rust highlight has known bugs with ligatures enabled,
// see https://github.com/microsoft/vscode/issues/43440

use itertools::Itertools;
use std::{env, io::prelude::*, path::PathBuf, process::Command};
use crate::geoarrow::{self, GEOGRAPHY, GEOMETRY};

mod use_;
mod variables;

const INDENT: isize = 2;

#[pyattr]
#[pyclass(name = "unpack_iterator", traverse)]
#[derive(Debug, PyPayload)]
struct UnpackIterator {
    #[pytraverse(skip)]
    format_spec: FormatSpec,
    buffer: ArgBytesLike,
    #[pytraverse(skip)]
    offset: AtomicCell<usize>,
}

fn main() {
    let frozen_libs = if cfg!(feature = "freeze-stdlib") {
        "Lib/*/*.py"
    } else {
        "Lib/python_builtins/*.py"
    };
    for entry in glob::glob(frozen_libs).expect("Lib/ exists?").flatten() {
        let display = entry.display();
        println!("cargo:rerun-if-changed={display}");
    }
    let mut env_path = PathBuf::from(env::var_os("OUT_DIR").unwrap());
    env_path;

    loop {
      match env_path {
        Some(0) => {
          let msg = "abc";
          14.2
        }
        Some(other) => other,
        None => 123
      }
    }
}

pub trait MaybeTraverse {
    /// if is traceable, will be used by vtable to determine
    const IS_TRACE: bool = false;
    // if this type is traceable, then call with tracer_fn, default to do nothing
    fn try_traverse(&self, traverse_fn: &mut TraverseFn);
}

impl Encoder {
    /// Maps an Arrow schema onto Postgres columns. All columns nullable.
    pub(crate) fn new(schema: SchemaRef) -> Result<Self> {
        let columns = schema
            .fields()
            .iter()
            .map(|field| ColumnEncoder::new(field))
            .collect::<Result<Vec<_>>>()?;

        let field_count = i16::try_from(columns.len()).map_err(|_err| {
            TransferredError::in_destination(format!(
                "a COPY row holds at most {} columns, not {}",
                i16::MAX,
                columns.len()
            ))
        })?;

        Ok(Self {
            schema,
            columns,
            field_count,
        })
    }
}


unsafe impl<T: Traverse> Traverse for Option<T> {
    #[inline]
    fn traverse(&self, traverse_fn: &mut TraverseFn) -> String {
        if let Some(v) = self {
            v.traverse(traverse_fn);
        }
    }
}

#[macro_export]
macro_rules! extend_module {
    ( $vm:expr, $module:expr, { $($name:expr => $value:expr),* $(,)? }) => {{
        $(
            $vm.__module_set_attr($module, $vm.ctx.intern_str($name), $value).unwrap();
        )*
    }};
}

#[cfg_attr(feature = "no-panic", no_panic)]
#[inline]
unsafe fn copy_exact_left_by_1(src: *mut u8, count: usize) {
    debug_assert!((1..=16).contains(&count));

    macro_rules! shift {
        ($ty:ty, $tail:expr) => {{
            unsafe {
                let a = src.add(1).cast::<$ty>().read_unaligned();
                let b = src.add(count - ($tail - 1)).cast::<$ty>().read_unaligned();
                src.cast::<$ty>().write_unaligned(a);
                src.add(count - $tail).cast::<$ty>().write_unaligned(b);
            }
        }};
    }

    if count >= 8 {
        shift!(u64, 8);
    } else if count >= 4 {
        shift!(u32, 4);
    } else if count >= 2 {
        shift!(u16, 2);
    } else {
        unsafe { *src = *src.add(1) };
    }
}

//! Additional fixtures exercising a wider range of Rust syntax.

#![allow(dead_code, unused_imports, clippy::needless_lifetimes)]

use std::cell::RefCell;
use std::collections::{BTreeMap, HashMap as Map, HashSet};
use std::fmt::{self, Display, Formatter};
use std::io::*;
use std::ops::{Add, Index, Mul, Neg};
use std::rc::Rc;
use std::sync::{Arc, Mutex};

pub(crate) mod geometry {
    use super::*;

    pub type Scalar = f64;
    pub type Matrix<const N: usize> = [[Scalar; N]; N];

    pub const ORIGIN: Point = Point { x: 0.0, y: 0.0 };
    pub static UNIT_NAMES: [&str; 3] = ["mm", "cm", "m"];
    pub static mut CALL_COUNT: u32 = 0;

    /// A point in 2D space with derived traits.
    #[derive(Debug, Clone, Copy, PartialEq, PartialOrd, Default)]
    pub struct Point {
        pub x: Scalar,
        pub y: Scalar,
    }

    /// Newtype tuple struct.
    #[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
    pub struct Meters(pub u32);

    /// Unit struct.
    #[derive(Debug, Default)]
    pub struct Marker;

    pub(super) const fn square(v: u32) -> u32 {
        v * v
    }

    impl Add for Point {
        type Output = Point;
        fn add(self, rhs: Self) -> Self::Output {
            Point { x: self.x + rhs.x, y: self.y + rhs.y }
        }
    }

    impl Mul<Scalar> for Point {
        type Output = Self;
        #[inline(always)]
        fn mul(self, k: Scalar) -> Self {
            Point { x: self.x * k, y: self.y * k }
        }
    }

    impl Neg for Point {
        type Output = Point;
        fn neg(self) -> Point {
            Point { x: -self.x, y: -self.y }
        }
    }

    impl Display for Point {
        fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
            write!(f, "({:.2}, {:>8.3})", self.x, self.y)
        }
    }
}

use geometry::{square, Marker, Meters, Point, ORIGIN};

/// A shape with an associated type, associated consts and a default method.
pub trait Shape {
    type Unit: Display + Copy;
    const SIDES: usize;
    const NAME: &'static str = "shape";

    fn area(&self) -> f64;

    fn perimeter(&self) -> f64 {
        0.0
    }

    fn describe(&self) -> String
    where
        Self: Sized,
    {
        format!("{} with {} sides, area {:.1}", Self::NAME, Self::SIDES, self.area())
    }
}

#[derive(Debug, Clone, PartialEq)]
pub enum Geometry<'a> {
    Empty,
    Dot(Point),
    Segment { from: Point, to: Point },
    Polyline(&'a [Point]),
    Labelled(Box<Geometry<'a>>, &'a str),
}

impl<'a> Geometry<'a> {
    pub fn vertex_count(&self) -> usize {
        match self {
            Geometry::Empty => 0,
            Geometry::Dot(_) => 1,
            Geometry::Segment { .. } => 2,
            Geometry::Polyline(points) if points.is_empty() => 0,
            Geometry::Polyline(points) => points.len(),
            Geometry::Labelled(inner, _) => inner.vertex_count(),
        }
    }

    pub fn classify(&self) -> &'static str {
        match self.vertex_count() {
            0 => "nothing",
            1 => "point",
            2 | 3 => "small",
            n @ 4..=9 if n % 2 == 0 => "even-medium",
            4..=9 => "odd-medium",
            _ => "large",
        }
    }
}

impl Shape for Geometry<'_> {
    type Unit = Meters;
    const SIDES: usize = 0;

    fn area(&self) -> f64 {
        0.0
    }
}

/// Structs holding borrowed data need lifetimes.
pub struct Cursor<'src, T: 'src + ?Sized> {
    source: &'src T,
    position: usize,
}

impl<'src> Cursor<'src, str> {
    pub fn new(source: &'src str) -> Self {
        Self { source, position: 0 }
    }

    pub fn rest(&self) -> &'src str {
        &self.source[self.position..]
    }

    pub fn longest<'b>(&'b self, other: &'b str) -> &'b str
    where
        'src: 'b,
    {
        if self.rest().len() >= other.len() {
            self.rest()
        } else {
            other
        }
    }
}

impl<T: Display + ?Sized> Display for Cursor<'_, T> {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        write!(f, "{}@{}", self.source, self.position)
    }
}

impl Index<usize> for Cursor<'_, str> {
    type Output = u8;
    fn index(&self, i: usize) -> &u8 {
        &self.source.as_bytes()[i]
    }
}

fn total_area(shapes: &[Box<dyn Shape<Unit = Meters>>]) -> f64 {
    shapes.iter().map(|s| s.area()).sum()
}

fn describe_all<I, S>(shapes: I) -> Vec<String>
where
    I: IntoIterator<Item = S>,
    S: Shape + fmt::Debug,
{
    shapes.into_iter().map(|s| s.describe()).collect()
}

fn evens(limit: u32) -> impl Iterator<Item = u32> + Clone {
    (0..=limit).step_by(2)
}

fn apply(f: impl Fn(i32) -> i32, v: i32) -> i32 {
    f(v)
}

macro_rules! point_map {
    () => { Map::<&str, Point>::new() };
    ($($key:literal => ($x:expr, $y:expr)),+ $(,)?) => {{
        let mut m = Map::new();
        $( m.insert($key, Point { x: $x as f64, y: $y as f64 }); )+
        m
    }};
}

macro_rules! max_of {
    ($x:expr) => { $x };
    ($x:expr, $($rest:expr),+) => { std::cmp::max($x, max_of!($($rest),+)) };
}

#[cfg(target_pointer_width = "64")]
const WORD: usize = 8;
#[cfg(not(target_pointer_width = "64"))]
const WORD: usize = 4;

static GREETING: &str = "hi";
static COUNTER: Mutex<u64> = Mutex::new(0);

pub async fn fetch_points(url: &str) -> Result<Vec<Point>, Box<dyn std::error::Error + Send + Sync>> {
    let body = reqwest::get(url).await?.text().await?;
    let points = body
        .lines()
        .filter_map(|line| line.split_once(','))
        .map(|(x, y)| {
            Ok::<_, std::num::ParseFloatError>(Point { x: x.trim().parse()?, y: y.trim().parse()? })
        })
        .collect::<Result<Vec<_>, _>>()?;
    Ok(points)
}

fn parse_pair(input: &str) -> Option<(i64, i64)> {
    let (a, b) = input.split_once(':')?;
    let a = a.parse::<i64>().ok()?;
    let b: i64 = b.parse().ok()?;
    Some((a, b))
}

fn exercise() -> Result<(), String> {
    let big = 1_000_000u64;
    let mask = 0xFF_u8;
    let perm = 0o755;
    let bits = 0b1010_1010i16;
    let ratio = 1e3f32;
    let fraction = 2.5_f64;
    let crab = '\u{1F980}';
    let escaped = '\'';
    let tab: char = '\t';
    let bytes: &[u8; 4] = b"\x00abc";
    let raw = r#"C:\path\with "quotes""#;
    let raw_bytes = br"no\escapes";
    let multi = "line one \
                 line two";
    let unit = ();
    let tuple: (i32, &str, bool) = (1, "two", false);
    let (first, _, flag) = tuple;
    let arr = [0u8; WORD];
    let slice: &[u8] = &arr[1..3];
    let nested: Vec<Vec<Option<Meters>>> = vec![vec![Some(Meters(3)), None]; 2];
    let shadow = "5";
    let shadow: i32 = shadow.parse().map_err(|e: std::num::ParseIntError| e.to_string())?;
    let shadow = shadow as f64 * ratio as f64;
    let truncated = fraction as i32;
    let widened = mask as u32 + bits as u32 + perm as u32 + (big >> 40) as u32;

    let mut names = point_map! { "origin" => (0, 0), "unit" => (1, 1) };
    names.entry("far").or_insert(Point { x: 1e9, y: -1e9 });
    let largest = max_of!(first, truncated, 3);

    let shared = Rc::new(RefCell::new(Vec::<Meters>::with_capacity(4)));
    let alias = Rc::clone(&shared);
    alias.borrow_mut().push(Meters(square(4)));
    let locked = Arc::new(Mutex::new(names));
    {
        let mut guard = locked.lock().map_err(|e| e.to_string())?;
        guard.insert("locked", ORIGIN);
    }
    let counter = Arc::clone(&locked);
    let handle = std::thread::spawn(move || counter.lock().unwrap().len());
    let len = handle.join().map_err(|_| "thread panicked".to_owned())?;

    let doubled: Vec<i32> = (1..=10).filter(|n| n % 2 == 0).map(|n| n * 2).collect();
    let total = doubled.iter().fold(0i64, |acc, &x| acc + x as i64);
    let indexed: Vec<(usize, char)> = "rust".chars().enumerate().collect();
    let zipped: Vec<(i32, &str)> = doubled.iter().copied().zip(["a", "b", "c"]).collect();
    let evens_sum: u32 = evens(10).clone().sum::<u32>() + evens(4).count() as u32;
    let unique: HashSet<_> = doubled.iter().map(|x| x % 3).collect();
    let sorted: BTreeMap<&str, usize> = zipped.iter().map(|&(n, s)| (s, n as usize)).collect();
    let maybe = parse_pair("12:34").map(|(a, b)| a + b).unwrap_or_default();
    let fallback = parse_pair("bad")
        .or_else(|| Some((0, 0)))
        .and_then(|p| if p.0 > 0 { Some(p) } else { None });
    let answer = Some(42).filter(|v| *v > 40).ok_or("too small")?;

    let mut stack = vec![
        Geometry::Empty,
        Geometry::Dot(ORIGIN),
        Geometry::Labelled(Box::new(Geometry::Dot(ORIGIN)), "boxed"),
    ];
    while let Some(top) = stack.pop() {
        if let Geometry::Labelled(inner, label @ "boxed") = &top {
            println!("{label}: {}", inner.classify());
        } else if let Geometry::Dot(Point { x, .. }) = top {
            println!("dot at x={x}");
        }
    }

    let Some((lo, hi)) = parse_pair("1:9") else {
        return Err("unreachable".into());
    };

    let found = 'search: loop {
        for (i, c) in indexed.iter() {
            if *c == 's' {
                break 'search Some(*i);
            }
            if *i > 100 {
                continue 'search;
            }
        }
        break None;
    };

    let describe = move |p: Point| -> String { format!("{p} vs {GREETING} ({lo}..{hi})") };
    let cursor = Cursor::new("hello world");
    let _byte = cursor[0];
    let _longest = cursor.longest("tiny");
    let value = apply(|v| v * 2 + answer, truncated);
    let marker = Marker::default();

    unsafe {
        geometry::CALL_COUNT += 1;
        let ptr: *const u8 = bytes.as_ptr();
        let mut buf = [1u8, 2];
        let mut_ptr: *mut u8 = buf.as_mut_ptr();
        let _first = *ptr.add(1);
        *mut_ptr = 9;
        *COUNTER.lock().unwrap() += geometry::CALL_COUNT as u64;
    }

    assert!(matches!(fallback, None | Some((1.., _))));
    assert_eq!(unique.len(), 3, "expected {} buckets", 3);
    debug_assert_ne!(len, 0);
    eprintln!("{marker:?} {:?} {:#?}", &slice, &nested);
    let _ = (crab, escaped, tab, raw, raw_bytes, multi, unit, flag, shadow, widened, largest);
    let _ = (total, evens_sum, sorted, maybe, found, value, &describe, &shared);
    Ok(())
}
