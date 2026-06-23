@echo off
echo ========================================
echo Building DIGITRANS-CM Project
echo ========================================

echo.
echo Building parent project...
call mvn clean install -DskipTests

echo.
echo ========================================
echo Build completed!
echo ========================================
echo.
echo To run with Docker:
echo   docker-compose up --build
echo.
echo To run locally:
echo   cd erp-service ^&^& mvn spring-boot:run
echo   cd crm-service ^&^& mvn spring-boot:run
echo   cd supply-chain-service ^&^& mvn spring-boot:run
echo   cd bi-service ^&^& mvn spring-boot:run
echo.
pause
