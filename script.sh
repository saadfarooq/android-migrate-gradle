gradle init
echo -n "include " > settings.gradle;

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
  echo "apply plugin: 'com.android.application'

android {
    compileSdkVersion 23
    buildToolsVersion \"23.0.0\"

    defaultConfig {
        minSdkVersion 7
        targetSdkVersion 22
    }
}

dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
    compile 'com.android.support:support-v4:23.0.0'
}
" > $dname/../build.gradle;

  # Add current project to settings.gradle
  echo -n \':`dirname ${dname##*./}`\' >> settings.gradle;

  # Final comments
  echo "Processing of " $dname "done. ";
  echo;
done

# Remove the last "," in settings.gradle
sed -i "s/''/', '/" settings.gradle;

# Add all project configuration to build.gradle in project root directory.
echo "buildscript {
  repositories {
      jcenter()
  }
  dependencies {
      classpath 'com.android.tools.build:gradle:1.3.0'
  }
}

allprojects {
    repositories {
        jcenter()
    }
}
" > build.gradle;

# Remove IDE specific files
rm -r .idea

# Copy Gradle stuff from ANDROID_HOME if possible
[ -n "$ANDROID_HOME" ] && \
cp $ANDROID_HOME/tools/templates/gradle/wrapper/* -r ./;
