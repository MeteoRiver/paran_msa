#!/bin/bash

# IntelliJ IDEA JDK 경로, 실제 경로로 변경해주세요
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"

# 모듈 리스트
all_modules=("server:api-gateway" "server:config-server" "server:eureka-server"
             "service:user-service" "service:auth-service" "service:chat-service"
             "service:admin-service" "service:post-service" "service:shop-service"
             "service:community-service" "service:review-service")

# Gradle clean
echo "Cleaning..."
./gradlew clean

# Gradle BootJar
for module in "${all_modules[@]}"
do
  echo "Building BootJar for $module"
  ./gradlew :$module:bootJar