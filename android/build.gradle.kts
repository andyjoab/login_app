buildscript {
    //ext.kotlin_version = "1.9.22" // <<< ASEGÚRATE DE QUE ESTA ES TU VERSIÓN ACTUAL DE KOTLIN
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Plugin de Android Gradle - Asegúrate de que sea una versión compatible con tu Flutter SDK
        classpath("com.android.tools.build:gradle:8.4.0") // O la que estés usando, ej: 8.4.0 o superior
        // Plugin de Kotlin Gradle
       // classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        // Plugin de Google Services para Firebase
        classpath("com.google.gms:google-services:4.4.1") // <<< Última versión conocida a Jun 2025 o superior
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
configurations.all {
        resolutionStrategy {
            // Evita conflictos de versiones de Firebase
            force("com.google.firebase:firebase-auth-ktx:23.2.0") // Actualiza a la versión que necesites
            force("com.google.firebase:firebase-firestore-ktx:24.4.0") // Actualiza a la versión que necesites
            force("com.google.firebase:firebase-storage-ktx:20.3.0") // Actualiza a la versión que necesites
            force("com.google.firebase:firebase-analytics-ktx:21.2.0") // Actualiza a la versión que necesites
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}