use typst_macros::elem;

use crate::diag::bail;
use crate::foundations::{BundlePath, Bytes, ShowFn, Str, cast};
use crate::introspection::Locatable;

/// Adds a custom file to a bundle.
///
/// This function creates a single file in a @reference:bundle[bundle], from
/// @bytes[raw byte data]. Unlike @document[documents], assets will be emitted
/// as-is without undergoing compilation.
///
/// This function may only be used in the @reference:bundle[bundle] target.
#[elem(Locatable)]
pub struct AssetElem {
    /// The path in the bundle at which the asset will be placed.
    ///
    /// May contain interior slashes, in which case intermediate directories
    /// will be automatically created.
    #[required]
    pub path: BundlePath,

    /// The raw data that will be written into the file at the specified path.
    ///
    /// If a string is given, it will be encoded using UTF-8.
    #[required]
    pub data: AssetData,
}

pub const ASSET_UNSUPPORTED_RULE: ShowFn<AssetElem> = |elem, _, _| {
    bail!(
        elem.span(),
        "assets are only supported in the bundle target";
        // TODO: Support for CLI-specific hints would be nice.
        hint: "try enabling the bundle target";
    )
};

/// The raw data for an asset.
#[derive(Debug, Clone, Eq, PartialEq, Hash)]
pub struct AssetData(pub Bytes);

cast! {
    AssetData,
    self => self.0.into_value(),
    v: Str => Self(Bytes::from_string(v)),
    v: Bytes => Self(v),
}
