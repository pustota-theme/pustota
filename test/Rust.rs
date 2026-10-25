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
    env_path

    loop {
      match env_path {
        Some(0) => {
          let msg = "abc";
          14.2
        }
        Some(other) => other
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
