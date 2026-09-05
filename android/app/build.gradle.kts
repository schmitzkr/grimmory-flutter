plugins {
    id("com.android.application")
    // AGP 9 has Kotlin support built in — no separate kotlin-android plugin
    // (and no kotlinOptions block), same as Flutter 3.47's own template.
    // The Flutter Gradle Plugin must be applied after the Android plugin.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: CI (release.yml/dev-build.yml) decodes a keystore from
// the KEYSTORE_BASE64 repo secret and exports these four env vars before
// building. Falls back to the debug keystore when they're unset (e.g. local
// `flutter run --release` on a dev machine without the real keystore) —
// that fallback must NEVER be used for an actual published release, since
// Android requires every update to an app be signed with the same key.
val envKeystorePath: String? = System.getenv("KEYSTORE_PATH")
val envKeystorePassword: String? = System.getenv("KEYSTORE_PASSWORD")
val envKeyAlias: String? = System.getenv("KEY_ALIAS")
val envKeyPassword: String? = System.getenv("KEY_PASSWORD")
val hasReleaseSigning =
    !envKeystorePath.isNullOrBlank() &&
        !envKeystorePassword.isNullOrBlank() &&
        !envKeyAlias.isNullOrBlank() &&
        !envKeyPassword.isNullOrBlank()

android {
    namespace = "is.schmitzkr.grimmory"
    // Explicit rather than flutter.compileSdkVersion (36 on Flutter 3.47):
    // flutter_secure_storage 11 needs 37. Requires AGP 9.x — 8.11 could not
    // resolve the SDK 37 platform even after auto-installing it.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "is.schmitzkr.grimmory"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // OIDC login is pure Dart (oidc_core + url_launcher + app_links —
        // see lib/features/auth/oidc_login_controller.dart); the redirect
        // intent-filter lives on MainActivity in AndroidManifest.xml. No
        // AppAuth plugin, so no ${appAuthRedirectScheme} placeholder.
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(envKeystorePath!!)
                storePassword = envKeystorePassword
                keyAlias = envKeyAlias
                keyPassword = envKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // Local `flutter run --release` on a dev machine without the
                // real keystore — never used by CI, which always has it.
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
