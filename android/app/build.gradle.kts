plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.wiihope"
    
    // ====== VERSIONES ACTUALIZADAS PARA COMPATIBILIDAD ======
    compileSdk = 36      // ✅ Actualizado de 34 a 36
    ndkVersion = "27.0.12077973"  // ✅ Actualizado de 25.1.8937393

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.wiihope"
        
        // ====== VERSIONES ACTUALIZADAS PARA AUDIO ======
        minSdk = flutter.minSdkVersion      // Android 5.0 - Mínimo para audio_service
        targetSdk = 34   // Mantener en 34 por estabilidad
        
        versionCode = 1
        versionName = "1.0.0"
        
        // ====== SOPORTE MULTIDEX (si crece la app) ======
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            
            // ====== OPTIMIZACIONES PARA RELEASE ======
            isMinifyEnabled = false
            isShrinkResources = false
        }
        
        debug {
            // ====== CONFIGURACIÓN PARA DEBUG ======
            isDebuggable = true
        }
    }
    
    // ====== CONFIGURACIÓN DE PACKAGING ======
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

flutter {
    source = "../.."
}

// ====== DEPENDENCIAS ======
dependencies {
    // Multidex support (opcional, pero recomendado)
    implementation("androidx.multidex:multidex:2.0.1")
}
