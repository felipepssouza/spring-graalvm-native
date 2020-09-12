#! /usr/bin/pwsh
pushd "D:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools"
cmd /c "VsDevCmd.bat&set" |
        foreach {
            if ($_ -match "=") {
                $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
            }
        }
popd
Write-Host "`nVisual Studio 2017 Command Prompt variables set." -ForegroundColor Yellow

$ARTIFACT="function-aws"
$MAINCLASS="com.example.demo.DemoApplication"
$VERSION="0.0.1-SNAPSHOT"

$GREEN="\033[0;32m"
$RED="\033[0;31m"
$NC="\033[0m"

$TARGET_FOLDER="target\"
if (Test-Path $TARGET_FOLDER) {
    Remove-Item $TARGET_FOLDER -Recurse -Force -Confirm:$false
}
New-Item -ItemType directory -Path target\native-image

echo "Packaging $ARTIFACT with Maven"
mvn -ntp package > target/native-image/output.txt
$JAR="$ARTIFACT-$VERSION.jar"

if (Test-Path $ARTIFACT) {
    Remove-Item $ARTIFACT -Recurse -Force -Confirm:$false
}

echo "Unpacking $JAR"
cd target/native-image
(jar -xvf ../$JAR) | out-null
cp -R META-INF BOOT-INF/classes

$LIBPATH= (Get-ChildItem -Path BOOT-INF/lib -Recurse -File |
        Group-Object -Property Directory |
        ForEach-Object {
            @(
            $_.Group |
                    Resolve-Path -Relative |   # make relative path
            ForEach-Object Substring 2 # cut '.\' part
            )-join';'
        })
$CP="BOOT-INF/classes;$LIBPATH\lib"
$GRAALVM_VERSION=(native-image --version)
echo "Compiling $ARTIFACT with $GRAALVM_VERSION"
#native-image --verbose -H:Name=$ARTIFACT -Dspring.native.remove-yaml-support=true -cp "$CP" $MAINCLASS >> output.txt
native-image --verbose -H:Name=$ARTIFACT -cp "$CP" $MAINCLASS >> output.txt

if ($ARTIFACT) {
    echo "${GREEN}SUCCESS${NC}\n"
    exit 0
} else {
    cat output.txt
    echo "${RED}FAILURE${NC}: an error occurred when compiling the native-image.\n"
    exit 1
}

#native-image --verbose -H:Name=function-aws -cp BOOT-INF\classes;BOOT-INF\lib\nio-multipart-parser-1.1.0.jar;BOOT-INF\lib\log4j-api-2.13.3.jar;BOOT-INF\lib\jul-to-slf4j-1.7.30.jar;BOOT-INF\lib\spring-boot-autoconfigure-2.4.0-M2.jar;BOOT-INF\lib\spring-cloud-function-adapter-aws-3.1.0-SNAPSHOT.jar;BOOT-INF\lib\spring-beans-5.3.0-M2.jar;BOOT-INF\lib\reactor-netty-core-1.0.0-M2.jar;BOOT-INF\lib\slf4j-api-1.7.30.jar;BOOT-INF\lib\spring-boot-starter-logging-2.4.0-M2.jar;BOOT-INF\lib\netty-codec-socks-4.1.51.Final.jar;BOOT-INF\lib\spring-boot-starter-json-2.4.0-M2.jar;BOOT-INF\lib\netty-handler-4.1.51.Final.jar;BOOT-INF\lib\netty-codec-dns-4.1.51.Final.jar;BOOT-INF\lib\spring-cloud-function-context-3.1.0-SNAPSHOT.jar;BOOT-INF\lib\netty-common-4.1.51.Final.jar;BOOT-INF\lib\spring-boot-starter-2.4.0-M2.jar;BOOT-INF\lib\spring-cloud-function-web-3.1.0-SNAPSHOT.jar;BOOT-INF\lib\logback-classic-1.2.3.jar;BOOT-INF\lib\netty-resolver-4.1.51.Final.jar;BOOT-INF\lib\netty-resolver-dns-4.1.51.Final.jar;BOOT-INF\lib\spring-graalvm-native-0.8.1-SNAPSHOT.jar;BOOT-INF\lib\netty-codec-4.1.51.Final.jar;BOOT-INF\lib\snakeyaml-1.26.jar;BOOT-INF\lib\netty-buffer-4.1.51.Final.jar;BOOT-INF\lib\spring-expression-5.3.0-M2.jar;BOOT-INF\lib\jackson-annotations-2.11.2.jar;BOOT-INF\lib\spring-boot-starter-reactor-netty-2.4.0-M2.jar;BOOT-INF\lib\spring-jcl-5.3.0-M2.jar;BOOT-INF\lib\typetools-0.6.2.jar;BOOT-INF\lib\spring-web-5.3.0-M2.jar;BOOT-INF\lib\spring-core-5.3.0-M2.jar;BOOT-INF\lib\javax.annotation-api-1.3.2.jar;BOOT-INF\lib\netty-transport-4.1.51.Final.jar;BOOT-INF\lib\reactor-core-3.4.0-M2.jar;BOOT-INF\lib\spring-boot-starter-webflux-2.4.0-M2.jar;BOOT-INF\lib\netty-handler-proxy-4.1.51.Final.jar;BOOT-INF\lib\logback-core-1.2.3.jar;BOOT-INF\lib\joda-time-2.9.9.jar;BOOT-INF\lib\spring-messaging-5.3.0-M2.jar;BOOT-INF\lib\spring-context-5.3.0-M2.jar;BOOT-INF\lib\jackson-module-parameter-names-2.11.2.jar;BOOT-INF\lib\log4j-to-slf4j-2.13.3.jar;BOOT-INF\lib\netty-codec-http-4.1.51.Final.jar;BOOT-INF\lib\spring-boot-jarmode-layertools-2.4.0-M2.jar;BOOT-INF\lib\netty-transport-native-unix-common-4.1.51.Final.jar;BOOT-INF\lib\jackson-datatype-jdk8-2.11.2.jar;BOOT-INF\lib\spring-boot-2.4.0-M2.jar;BOOT-INF\lib\netty-codec-http2-4.1.51.Final.jar;BOOT-INF\lib\reactive-streams-1.0.3.jar;BOOT-INF\lib\nio-stream-storage-1.1.3.jar;BOOT-INF\lib\jackson-datatype-jsr310-2.11.2.jar;BOOT-INF\lib\jackson-datatype-joda-2.11.2.jar;BOOT-INF\lib\netty-transport-native-epoll-4.1.51.Final-linux-x86_64.jar;BOOT-INF\lib\jackson-databind-2.11.2.jar;BOOT-INF\lib\jackson-core-2.11.2.jar;BOOT-INF\lib\spring-cloud-function-core-3.1.0-SNAPSHOT.jar;BOOT-INF\lib\jakarta.annotation-api-1.3.5.jar;BOOT-INF\lib\spring-aop-5.3.0-M2.jar;BOOT-INF\lib\reactor-netty-http-1.0.0-M2.jar;BOOT-INF\lib\spring-webflux-5.3.0-M2.jar com.example.demo.DemoApplication