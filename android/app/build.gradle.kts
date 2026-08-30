plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "is.schmitzkr.grimmory"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "is.schmitzkr.grimmory"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Required by the oidc package's Android implementation (AppAuth) —
        // it declares a manifest placeholder for the OAuth redirect's custom
        // URI scheme; the manifest merger fails without it, even though this
        // app doesn't actually use AppAuth's own redirect activity (OIDC
        // login is handled via app_links + DeepLinkOidcUserManager instead,
        // see lib/features/auth/). Must match the scheme used for the OIDC
        // redirect URI (is.schmitzkr.grimmory://oidc-callback) — do NOT also
        // register this scheme as an intent-filter on MainActivity, which
        // would create a disambiguation dialog against AppAuth's own
        // (unused) RedirectUriReceiverActivity.
        manifestPlaceholders["appAuthRedirectScheme"] = "is.schmitzkr.grimmory"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
