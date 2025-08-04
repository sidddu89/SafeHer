<<<<<<< HEAD
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("com.google.gms:google-services:4.3.15")
    }
}

plugins {
  // ...
  // (Do not add com.google.gms.google-services here for Groovy app/build.gradle projects)
}


=======
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
<<<<<<< HEAD
subprojects 
{
=======
subprojects {
>>>>>>> c2244a550e48377e839327453b2e2f0c42eb59e4
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
