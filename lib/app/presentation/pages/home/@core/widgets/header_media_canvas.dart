import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/home_promo_banner_media.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/home_promo_banner_model.dart';
import 'package:user/app/presentation/styles/debug_trace.dart';

/// Which slice of the shared header canvas a surface shows.
enum HeaderMediaWindow {
  /// The top slice, painted by the app bar.
  top,

  /// The bottom slice, painted by the banner slot.
  bottom,
}

/// Paints one surface's slice of the single media canvas that spans the whole header.
///
/// The app bar and the banner are separate widgets in separate parts of the tree, so each
/// builds its own window here rather than sharing an instance. They still line up: both
/// lay the media out against the SAME canvas box (`canvasWidth x canvasHeight`) with the
/// same fit, so the picture does not restart at the seam - the app bar simply reveals the
/// top of it and the banner the bottom.
///
/// That is the whole trick. Laying each surface out independently against its own box is
/// what produces the duplicated-image seam; laying both against one canvas and clipping
/// is what makes it read as a single continuous header.
///
/// For Lottie the canvas is the composition frame, so a full-bleed background animation
/// flows across the seam exactly as an image would.
class HeaderMediaCanvasWindow extends StatelessWidget {
  final HomePromoBannerSpec spec;
  final HeaderMediaLayout layout;
  final HeaderMediaWindow window;

  /// Playback shared by both halves of a header, so the two windows show one frame.
  final AnimationController? mediaController;

  /// Scroll-driven pan of the canvas, shared by both windows.
  ///
  /// One notifier feeds both windows, so the app bar and the banner cannot pan by different
  /// amounts and tear at the split.
  final ValueListenable<double>? parallax;

  /// Size of this surface's own box. The window is clipped to it.
  final double width;
  final double height;

  const HeaderMediaCanvasWindow({
    super.key,
    required this.spec,
    required this.layout,
    required this.window,
    required this.width,
    required this.height,
    this.mediaController,
    this.parallax,
  });

  /// Each window's own box, remembered until its sibling has reported.
  ///
  /// The two windows live in different subtrees, so nothing else ever compares them. An
  /// earlier version compared BOTH slices against whichever window happened to be
  /// building, which meant the check could never pass - from the app bar it compared the
  /// banner's 170px slice against the app bar's own 119px box. It reported MISMATCH
  /// unconditionally and so proved nothing. Each window is now held to its OWN slice, and
  /// only the summed slices are checked against the canvas.
  static final Map<String, double> _seenBoxes = {};

  void _traceVerdict() {
    if (!DebugTrace.enabled) return;
    _seenBoxes[window.name] = height;
    final double? topBox = _seenBoxes['top'];
    final double? bottomBox = _seenBoxes['bottom'];
    if (topBox == null || bottomBox == null) return;
    final double appBarSlice = layout.appBarHeight;
    final double bannerSlice = layout.bannerHeight;
    final bool contiguous = (topBox - appBarSlice).abs() < 0.5 &&
        (bottomBox - bannerSlice).abs() < 0.5 &&
        (appBarSlice + bannerSlice - layout.canvasHeight).abs() < 0.5;
    DebugTrace.log(
      'HeaderMediaCanvas',
      'VERDICT ${contiguous ? 'CONTIGUOUS' : 'MISMATCH'} | '
      'canvas=${layout.canvasHeight.toStringAsFixed(1)} | '
      'topBox=${topBox.toStringAsFixed(1)} vs slice ${appBarSlice.toStringAsFixed(1)} | '
      'bottomBox=${bottomBox.toStringAsFixed(1)} vs slice ${bannerSlice.toStringAsFixed(1)} | '
      'fit=${spec.lottieFit}',
    );
  }

  @override
  Widget build(BuildContext context) {
    _traceVerdict();

    // One media widget laid out against the full canvas.
    //
    // Zoom and nudge are applied HERE, on the canvas, rather than per window. Applied per
    // window each surface would crop against its own scale about its own centre, which is
    // precisely the "artwork shifts at the split" failure: the two halves would stop
    // describing one picture. Applied here, both windows reveal the same transformed
    // canvas, and it matches what the admin preview draws.
    // Box and transform, sized explicitly from the layout.
    //
    // The box is stated OUTSIDE the transform so the canvas this window clips into is a
    // single, self-evident `width x paintedCanvasHeight` rather than something inferred
    // from the nesting of the nodes inside it. The operator's zoom and nudge are applied
    // inside that box and nowhere else, so the pan below can never be entangled with them.
    final Widget media = SizedBox(
      width: layout.width,
      height: layout.paintedCanvasHeight,
      child: Transform.scale(
        // Deliberately the default centre alignment, and it has to stay that way.
        //
        // The admin preview scales about the centre too - its stylesheet sets no
        // `transform-origin` anywhere, so the CSS default of 50% 50% applies, and the
        // comment on `previewMediaTransform` states it matches the client. Anchoring to
        // the top-left here would zoom toward a corner while the operator is dragging a
        // centre-anchored rail in the preview, so the picture would sit differently in the
        // two places it is meant to look identical.
        //
        // It would also make the shared header behave unlike a standalone banner, which
        // scales about the centre in `HomePromoBanner` - reintroducing exactly the kind
        // of split behaviour this header has been fighting all along.
        //
        // Neither alignment breaks the seam: both windows transform the same
        // `paintedCanvasHeight` box, so whatever they show stays adjoining.
        scale: spec.mediaScale,
        child: FractionalTranslation(
          translation: spec.mediaOffset,
          child: HomePromoBannerMedia(
            spec: spec,
            width: layout.width,
            height: layout.paintedCanvasHeight,
            slot: window.name,
            externalController: mediaController,
          ),
        ),
      ),
    );

    // Parallax panning.
    //
    // The two windows must ALWAYS show adjoining ranges of one canvas, or the header
    // tears at the split. That is guaranteed here by construction rather than by
    // agreement: the app bar's window starts at the pan offset, and the banner's starts at
    // the pan offset plus the app bar's height. Any pan in range keeps them touching.
    //
    // The pan moves through `overscan` of extra canvas rendered above and below the
    // visible region, so there is always real media under every window at every offset -
    // the artwork can never run out and leave a bare edge.
    // `child:` so a scroll tick re-positions the clip without rebuilding the Lottie.
    return ValueListenableBuilder<double>(
      valueListenable: parallax ?? _FixedValue(layout.overscan),
      builder: (BuildContext context, double value, Widget? child) {
        final double row = window == HeaderMediaWindow.top
            ? value
            : value + layout.appBarHeight;
        return ClipRect(
          child: SizedBox(
            width: width,
            height: height,
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: layout.width,
              maxWidth: layout.width,
              minHeight: layout.paintedCanvasHeight,
              maxHeight: layout.paintedCanvasHeight,
              child: Transform.translate(
                offset: Offset(0, -row),
                child: child,
              ),
            ),
          ),
        );
      },
      child: media,
    );
  }
}

/// Stand-in notifier so the window needs no null check when parallax is switched off.
class _FixedValue implements ValueListenable<double> {
  const _FixedValue(this._value);
  final double _value;

  @override
  double get value => _value;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}
