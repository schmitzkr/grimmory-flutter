plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
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
    // Hardcoded rather than flutter.compileSdkVersion (still 36 as of
    // Flutter 3.47.2) -- flutter_secure_storage 11.x requires compiling
    // against SDK 37. Bump this if a future Flutter release's own default
    // catches up, but don't drop below whatever the newest dependency
    // actually needs.
    compileSdk = 37
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
