//! Data loading.

use comemo::Tracked;
use typst_syntax::{FileId, Spanned};

use crate::World;
use crate::diag::{At, HintedString, SourceResult};
use crate::foundations::{Bytes, OneOrMultiple, PathOrStr, cast};

/// Something we can retrieve byte data from.
#[derive(Debug, Clone, PartialEq, Hash)]
pub enum DataSource {
    /// A path to a file.
    Path(PathOrStr),
    /// Raw bytes.
    Bytes(Bytes),
}

cast! {
    DataSource,
    self => match self {
        Self::Path(v) => v.into_value(),
        Self::Bytes(v) => v.into_value(),
    },
    v: PathOrStr => Self::Path(v),
    v: Bytes => Self::Bytes(v),
}

/// Loads data from a path or provided bytes.
pub trait Load {
    /// Bytes or a list of bytes (if there are multiple sources).
    type Output;

    /// Load the bytes.
    fn load(&self, world: Tracked<dyn World + '_>) -> SourceResult<Self::Output>;
}

impl Load for Spanned<DataSource> {
    type Output = Loaded;

    fn load(&self, world: Tracked<dyn World + '_>) -> SourceResult<Self::Output> {
        self.as_ref().load(world)
    }
}

impl Load for Spanned<&DataSource> {
    type Output = Loaded;

    fn load(&self, world: Tracked<dyn World + '_>) -> SourceResult<Self::Output> {
        match self.v {
            DataSource::Path(path) => {
                let resolved =
                    path.resolve_if_some(self.span.id()).at(self.span)?.intern();
                let data = world
                    .file(resolved)
                    .map_err(|error| {
                        let mut hinted = HintedString::from(error);
                        if let PathOrStr::Str(string) = &path
                            && (string.as_str().starts_with("http://")
                                || string.as_str().starts_with("https://"))
                        {
                            hinted.hint("network access is not supported");
                        }
                        hinted
                    })
                    .at(self.span)?;
                let source = Spanned::new(LoadSource::Path(resolved), self.span);
                Ok(Loaded::new(source, data))
            }
            DataSource::Bytes(data) => {
                let source = Spanned::new(LoadSource::Bytes, self.span);
                Ok(Loaded::new(source, data.clone()))
            }
        }
    }
}

impl Load for Spanned<OneOrMultiple<DataSource>> {
    type Output = Vec<Loaded>;

    fn load(&self, world: Tracked<dyn World + '_>) -> SourceResult<Self::Output> {
        self.as_ref().load(world)
    }
}

impl Load for Spanned<&OneOrMultiple<DataSource>> {
    type Output = Vec<Loaded>;

    fn load(&self, world: Tracked<dyn World + '_>) -> SourceResult<Self::Output> {
        self.v
            .0
            .iter()
            .map(|source| Spanned::new(source, self.span).load(world))
            .collect()
    }
}

/// Data loaded from a [`DataSource`].
#[derive(Debug, Clone, Eq, PartialEq, Hash)]
pub struct Loaded {
    /// Details about where `data` was loaded from.
    pub source: Spanned<LoadSource>,
    /// The loaded data.
    pub data: Bytes,
}

impl Loaded {
    pub fn new(source: Spanned<LoadSource>, bytes: Bytes) -> Self {
        Self { source, data: bytes }
    }
}

/// A loaded [`DataSource`].
#[derive(Debug, Copy, Clone, Eq, PartialEq, Hash)]
pub enum LoadSource {
    Path(FileId),
    Bytes,
}
