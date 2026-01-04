$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17"
$env:Path = "$env:JAVA_HOME\bin;" + $env:Path
Write-Host "Java version check:"
java -version
Write-Host "Flutter doctor check:"
flutter doctor
