echo "include " > settings.gradle;

# Loop through the sub-project directories
for dname in `find -name src`;do 
  # Remove ant stuff
  echo "Removing ant generated folders";
  rm -r -f $dname/../bin;
  rm -r -f $dname/../gen;

  echo "Creating; src directory" $dname/main;  
  mkdir $dname/main; 
  echo "Creating java src directory" $dname/main;  
  mkdir $dname/main/java;
  # Copy old stuff to new paths
  echo "Copying Manifest from " $dname/../ to $dname/main;
  cp $dname/../AndroidManifest.xml $dname/main/;
  echo "Moving code to new 'main' folder";
  for srcs in `ls $dname`; do
    [[ $srcs != "main" ]] && mv $dname/$srcs $dname/main/java \
    && echo "Movings source dir "$srcs ;
  done
  # Create test directory
  echo "Creating test directory" $dname/test;  
  mkdir $dname/test;

  echo "Moving resources to new 'resource' folder " $dname/main/res ;
  mv $dname/../res $dname/main/;
  echo "Removing unnecessary files";
  for file in `ls $dname/../`; do 
    [[ -f $dname/../$file ]] && rm $dname/../$file;
  done
  [[ -f build.gradle.template ]] && \
  echo "Copying gradle build file to modules" && \
  cp build.gradle.template $dname/../build.gradle

  # Create the default build.gradle file
  echo "buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:0.4'
    }
}
apply plugin: 'android'

dependencies {
    compile files('libs/android-support-v4.jar')
}

android {
    compileSdkVersion 17
    buildToolsVersion \"17.0.0\"

    defaultConfig {
        minSdkVersion 7
        targetSdkVersion 16
    }
}
" > $dname/../build.gradle;

  # Add current project to settings.gradle
  echo \':`dirname ${dname##*./}`\',\  >> settings.gradle;

  # Final comments
  echo "Processing of " $dname "done. ";
  echo;
done

# Remove IDE specific files
rm -r .idea

# Copy Gradle stuff from ANDROID_HOME if possible
[ -n "$ANDROID_HOME" ] && \
cp $ANDROID_HOME/tools/templates/gradle/wrapper/* -r ./;
