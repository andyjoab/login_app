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
    namespace = "com.example.login_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Update this to match your NDK version if necessarys
    //ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.login_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk =  23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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

dependencies {
    // Firebase BOM (Bill of Materials) - ¡MUY RECOMENDADO!
    // Esto asegura que todas tus librerías de Firebase utilicen versiones compatibles entre sí.
    // Utiliza la versión más reciente que te di (33.15.0 a Junio 2025 o superior si hay una más nueva)
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))

    // Dependencias de Firebase específicas, ya no necesitas especificar la versión individual
    // si usas el BoM, solo el nombre del módulo.
    //implementation("com.google.firebase:firebase-auth-ktx")        // Para autenticación
    //implementation("com.google.firebase:firebase-firestore-ktx")    // Para Cloud Firestore
    //implementation("com.google.firebase:firebase-storage-ktx")      // Para Firebase Storage (subida de archivos)
   // implementation("com.google.firebase:firebase-analytics-ktx")    // Si utilizas Firebase Analytics

    // Dependencia de Kotlin (si ya no la tienes o si usas Kotlin en tus plugins nativos)
    // Asegúrate de que la versión de Kotlin coincida con la que tienes en tu build.gradle.kts de nivel de proyecto
    
    //implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:${project.ext.kotlin_version}")

    // Las dependencias de Flutter que ya están incluidas automáticamente por el plugin de Flutter
    // no necesitas agregarlas manualmente aquí, a menos que tengas alguna específica.
    // implementation(flutter.embedding.engine) // Ya es manejado por el plugin de Flutter
}