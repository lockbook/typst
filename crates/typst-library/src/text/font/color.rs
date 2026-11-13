//! Utilities for glyphs without outlines

use ttf_parser::GlyphId;
use typst_syntax::Span;

use crate::layout::{Abs, Frame, FrameItem, Point, Size};
use crate::text::FontInstance;
use crate::visualize::{FixedStroke, Geometry, Shape};

/// Whether glyphs of this font should be rendered via simple outlining instead
/// of via `glyph_frame`.
pub fn should_outline(font: &FontInstance) -> bool {
    let ttf = font.ttf();
    ttf.tables().glyf.is_some()
        || ttf.tables().cff.is_some()
        || ttf.tables().cff2.is_some()
}

/// A frame that can draw a glyph.
#[derive(Clone)]
pub struct GlyphFrame {
    pub upem: Abs,
    pub item: GlyphFrameItem,
}

impl GlyphFrame {
    /// The font unit square.
    pub fn size(&self) -> Size {
        Size::splat(self.upem)
    }
}

impl From<GlyphFrame> for Frame {
    fn from(g: GlyphFrame) -> Self {
        let mut frame = Frame::soft(Size::splat(g.upem));
        match g.item {
            GlyphFrameItem::Tofu(pos, shape) => {
                frame.push(pos, FrameItem::Shape(shape, Span::detached()))
            }
        }
        frame
    }
}

/// The glyph item that is drawn.
#[derive(Clone)]
pub enum GlyphFrameItem {
    /// A fallback rectangle.
    Tofu(Point, Shape),
}

impl GlyphFrameItem {
    /// The position of the glyph item inside the parent frame.
    pub fn pos(&self) -> Point {
        match *self {
            GlyphFrameItem::Tofu(pos, _) => pos,
        }
    }
}

/// Returns a frame representing a glyph and whether it is a fallback tofu
/// frame.
///
/// Should only be called on glyphs for which [`should_outline`] returns false.
///
/// The glyphs are sized in font units, [`text.item.size`] is not taken into
/// account.
///
/// [`text.item.size`]: crate::text::TextItem::size
#[comemo::memoize]
pub fn glyph_frame(font: &FontInstance, glyph_id: u16) -> Option<GlyphFrame> {
    let upem = Abs::pt(font.units_per_em());
    let glyph_id = GlyphId(glyph_id);

    // Generate a fallback tofu if the glyph couldn't be drawn, unless it is
    // the space glyph. Then, an empty frame does the job. (This happens for
    // some rare CBDT fonts, which don't define a bitmap for the space, but
    // also don't have a glyf or CFF table.)
    let not_space = font.ttf().glyph_index(' ') != Some(glyph_id);
    not_space.then(|| draw_fallback_tofu(font, upem, glyph_id))
}

/// Draws a fallback tofu box with the advance width of the glyph.
fn draw_fallback_tofu(font: &FontInstance, upem: Abs, glyph_id: GlyphId) -> GlyphFrame {
    let advance = font
        .ttf()
        .glyph_hor_advance(glyph_id)
        .map(|advance| Abs::pt(advance as f64))
        .unwrap_or(upem / 3.0);
    let inset = 0.15 * advance;
    let height = 0.7 * upem;
    let pos = Point::new(inset, upem - height);
    let size = Size::new(advance - inset * 2.0, height);
    let thickness = upem / 20.0;
    let stroke = FixedStroke { thickness, ..Default::default() };
    let shape = Geometry::Rect(size).stroked(stroke);
    GlyphFrame { upem, item: GlyphFrameItem::Tofu(pos, shape) }
}
