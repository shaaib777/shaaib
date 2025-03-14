plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle Plugin
}

android {
    namespace = "com.example.untitled6"
    compileSdk = 34 // تأكد من أن هذا الإصدار متوافق مع إصدار Flutter الذي تستخدمه

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.untitled6"
        minSdk = 23 // يمكنك تغيير هذا الرقم حسب احتياجاتك
        targetSdk = 34 // تأكد من أن هذا الإصدار متوافق مع إصدار Flutter الذي تستخدمه
        versionCode = 1 // يمكنك تغيير هذا الرقم حسب احتياجاتك
        versionName = "1.0" // يمكنك تغيير هذا الرقم حسب احتياجاتك
    }

    buildTypes {
        release {
            // TODO: أضف إعدادات التوقيع الخاصة بك لإصدار التطبيق
            signingConfig = signingConfigs.getByName("debug") // استخدام توقيع التصحيح مؤقتًا
        }
    }
}

flutter {
    source = "../.."
}