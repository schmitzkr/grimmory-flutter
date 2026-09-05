import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-screen reading, shared by the EPUB, comic and PDF readers: hides
/// the app bar and toolbar (each reader does that itself) and the system
/// bars (this), and puts them back on the way out.
Future<void> setReaderImmersive(bool immersive) =>
    SystemChrome.setEnabledSystemUIMode(
      immersive ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );

/// The one control left on screen while the chrome is hidden — a
/// translucent button in the top corner, so leaving full screen never
/// depends on knowing the tap gesture.
class FullscreenExitButton extends StatelessWidget {
  const FullscreenExitButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: Colors.black38,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Exit full screen',
              color: Colors.white,
              icon: const Icon(Icons.fullscreen_exit),
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );
  }
}

/// App-bar action that enters full screen.
class FullscreenButton extends StatelessWidget {
  const FullscreenButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Full screen',
      icon: const Icon(Icons.fullscreen),
      onPressed: onPressed,
    );
  }
}
