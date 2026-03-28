# After running tests with code coverage in Visual Studio Code, you will see output similar to the following in the terminal:

# Created Coverage Controller
# CodeCoverage: Active run not initialized
# CodeCoverage: Report generated: C:\Users\alan\AppData\Local\Temp\567740532


# Convert it with dotnet-coverage
# Prerequisite: Install the dotnet-coverage tool if you haven't already:
dotnet tool install -g dotnet-coverage

# Convert to Cobertura XML
dotnet-coverage merge "C:\Users\alan\AppData\Local\Temp\567740532" -f cobertura -o coverage.xml