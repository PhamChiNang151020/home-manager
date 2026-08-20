/// iOS standalone PWA viewport helpers.
///
/// WebKit can report [innerHeight] shorter than the physical screen on cold
/// start while the page still paints edge-to-edge. Touch events only register
/// inside the shorter box, so bottom controls feel unresponsive or misaligned.
abstract final class PwaViewport {
  static double standaloneTouchGap({
    required double screenMaxDimension,
    required double innerHeight,
  }) {
    if (innerHeight <= 0) return 0;
    final gap = screenMaxDimension - innerHeight;
    return gap > 0 ? gap : 0;
  }
}
