import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// Adds tap-to-turn-page zones and a swipe-down gesture (plus an optional
/// swipe-up one) on top of [child] (the EPUB WebView) without disturbing its own swipe-to-turn-page
/// and text-selection handling.
///
/// Deliberately built on [Listener] (raw pointer routing) rather than a
/// [GestureDetector]/[PanGestureRecognizer]: `flutter_epub_viewer`'s
/// underlying `InAppWebView` already registers its own
/// `VerticalDragGestureRecognizer` to let vertical drags reach the WebView
/// platform view, and a second recognizer of the same kind fighting it in
/// the gesture arena would be unreliable. `Listener` never enters that
/// arena — with `HitTestBehavior.translucent` it just observes raw pointer
/// events alongside whatever the WebView does with them, so the existing
/// swipe/selection behavior is untouched.
class EpubGestureOverlay extends StatefulWidget {
  const EpubGestureOverlay({
    required this.child,
    required this.onTapLeft,
    required this.onTapRight,
    required this.onSwipeDown,
    this.onSwipeUp,
    this.onTap,
    this.onTapCenter,
    super.key,
  });

  final Widget child;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;
  final VoidCallback onSwipeDown;

  /// Optional: the reader stopped using swipe-up once Chapters got a
  /// toolbar button, so an unhandled upward swipe is simply left to the
  /// WebView.
  final VoidCallback? onSwipeUp;

  /// A tap in the middle third — the zone with no page-turn action, so a
  /// natural place for "show/hide the controls".
  final VoidCallback? onTapCenter;
  // Fires on every plain tap, in every zone, in addition to (and before)
  // any zone-specific callback above -- including the middle third, which
  // has no zone callback of its own. Lets the reader screen react to "the
  // user tapped somewhere" regardless of zone, e.g. to dismiss an active
  // text selection.
  final VoidCallback? onTap;

  @override
  State<EpubGestureOverlay> createState() => _EpubGestureOverlayState();
}

class _EpubGestureOverlayState extends State<EpubGestureOverlay> {
  Offset? _downPosition;
  int? _downTimeMs;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) {
              _downPosition = event.position;
              _downTimeMs = event.timeStamp.inMilliseconds;
            },
            onPointerUp: (event) {
              final downPosition = _downPosition;
              final downTimeMs = _downTimeMs;
              _downPosition = null;
              _downTimeMs = null;
              if (downPosition == null || downTimeMs == null) return;

              final delta = event.position - downPosition;
              final elapsedMs = event.timeStamp.inMilliseconds - downTimeMs;

              // Swipe down/up: mostly vertical, far enough, and quick
              // enough that a deliberate slow scroll through content (were
              // this book ever in scrolled flow) doesn't misfire.
              if (delta.dy.abs() > 80 &&
                  delta.dy.abs() > delta.dx.abs() * 1.5 &&
                  elapsedMs < 600) {
                if (delta.dy > 0) {
                  widget.onSwipeDown();
                  return;
                }
                if (widget.onSwipeUp != null) {
                  widget.onSwipeUp!();
                  return;
                }
              }

              // Tap: minimal movement, quick — anything else (a real
              // horizontal page-turn swipe, a text-selection drag) is left
              // alone for the WebView's own handling to have already seen.
              if (delta.distance < 12 && elapsedMs < 400) {
                widget.onTap?.call();
                final width = context.size?.width ?? 0;
                if (width <= 0) return;
                if (downPosition.dx < width * 0.3) {
                  widget.onTapLeft();
                } else if (downPosition.dx > width * 0.7) {
                  widget.onTapRight();
                } else {
                  // Middle third: no page-turn action; the page's own
                  // content (links, selection) still gets the tap too.
                  widget.onTapCenter?.call();
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
