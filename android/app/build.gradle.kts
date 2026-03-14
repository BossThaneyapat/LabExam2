plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    android {
    namespace = "com.example.ai_expense_tracker"
    
    // 1. แก้ compileSdk เป็น 34 (เวอร์ชันมาตรฐานปัจจุบัน)
    compileSdk = 36
    
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.ai_expense_tracker"
        
        // 2. แก้ minSdk เป็น 21 (เพื่อให้รันบน Android 5.0 ขึ้นไปได้ รวมถึง Emulator ของคุณด้วย)
        minSdk = flutter.minSdkVersion
        
        // 3. แก้ targetSdk เป็น 34
        targetSdk = 35
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
}
