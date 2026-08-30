package `is`.schmitzkr.grimmory

import com.ryanheise.audioservice.AudioServiceActivity

// AudioServiceActivity (not plain FlutterActivity) reuses the FlutterEngine
// that audio_service's background service manages, so playback survives
// this activity being destroyed/recreated (e.g. backgrounding the app).
class MainActivity : AudioServiceActivity()
