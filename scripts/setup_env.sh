#!/bin/bash
export JAVA_HOME="/c/Program Files/Android/Android Studio1/jbr"
export PATH="$JAVA_HOME/bin:$PATH"
echo "Java version check:"
java -version
echo "Flutter doctor check:"
flutter doctor
