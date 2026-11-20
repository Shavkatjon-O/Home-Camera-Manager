plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.detekt)
}

val camerasFile = rootProject.file("cameras.local.properties").takeIf { it.exists() }
    ?: rootProject.file("cameras.example.properties")
val camerasText = providers.fileContents(layout.projectDirectory.file(camerasFile.absolutePath)).asText.get()
val camerasLiteral = buildString {
    append('"')
    for (c in camerasText) {
        when (c) {
            '\\' -> append("\\\\")
            '"' -> append("\\\"")
            '\n' -> append("\\n")
            '\r' -> Unit
            else -> append(c)
        }
    }
    append('"')
}

android {
    namespace = "uz.smartsurveillance.tv"
    compileSdk = 37

    defaultConfig {
        applicationId = "uz.home.cameras.tv"
        minSdk = 23
        targetSdk = 36
        versionCode = 2
        versionName = "2.0.0"
        buildConfigField("String", "CAMERAS", camerasLiteral)
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }
}

dependencies {
    implementation(libs.kotlinx.coroutines.android)

    implementation(libs.androidx.core)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.lifecycle.runtime.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.foundation)
    implementation(libs.androidx.tv.material)

    testImplementation(libs.junit)
}

detekt {
    buildUponDefaultConfig = false
    config.setFrom(rootProject.file("config/detekt.yml"))
    source.setFrom("src/main/kotlin")
    ignoreFailures = true
}
