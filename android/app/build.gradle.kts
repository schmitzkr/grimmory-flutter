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
        // the native AppAuth library's manifest declares a redirect
        // intent-filter with an unresolved ${appAuthRedirectScheme}
        // placeholder; the manifest merger fails without a value, even
        // though this app doesn't actually use AppAuth's own redirect
        // activity (OIDC login goes through app_links +
        // DeepLinkOidcUserManager instead, see lib/features/auth/).
        //
        // Deliberately a DIFFERENT, unused scheme from the app's real OIDC
        // redirect URI (is.schmitzkr.grimmory://oidc-callback, registered on
        // MainActivity — see AndroidManifest.xml). AppAuth's manifest
        // declares its intent-filter with scheme-only matching (no host
        // restriction), so if this placeholder were set to the SAME scheme
        // our own redirect uses, both AppAuth's RedirectUriReceiverActivity
        // and MainActivity would match the incoming URI and Android would
        // show a disambiguation "open with" dialog on every OIDC login.
        manifestPlaceholders["appAuthRedirectScheme"] = "is.schmitzkr.grimmory.unused"
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
