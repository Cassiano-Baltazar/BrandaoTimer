plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.brandao.brandao_timer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.brandao.brandao_timer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Chave fixa para instalar o app direto no celular (fora da loja). Ser
    // sempre a mesma permite atualizar sem desinstalar, o que apagaria os
    // treinos salvos. Vem de variáveis de ambiente (secrets do GitHub); sem
    // elas, o build usa a chave de debug.
    val sideloadKeystore = System.getenv("SIDELOAD_KEYSTORE_PATH")
    val sideloadPassword = System.getenv("SIDELOAD_KEYSTORE_PASSWORD")
    val hasSideloadKey = !sideloadKeystore.isNullOrEmpty() && !sideloadPassword.isNullOrEmpty()

    signingConfigs {
        if (hasSideloadKey) {
            create("sideload") {
                storeFile = file(sideloadKeystore!!)
                storePassword = sideloadPassword
                keyAlias = "brandao"
                keyPassword = sideloadPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hasSideloadKey) "sideload" else "debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
