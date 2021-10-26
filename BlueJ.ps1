# Maven to BlueJ helper script
# Author: Pawel Makles <https://insrt.uk>
# Repository: https://github.com/KCLOSS/maven-bluej
# Version: 0.2

param (
    [switch]$Build = $false,
    [switch]$Run = $false,
    [switch]$NoClean = $false,

    [string]$BlueJ = "C:/Program Files/BlueJ/BlueJ.exe",
    [string]$TestDirectory = "test",
    [string]$OutFile = "target/bluej_out.jar",
    [string]$BuildCommand = "mvn clean compile assembly:single"
)

if ($Build) {
    # Build Maven project.
    Invoke-Expression $BuildCommand

    # Copy the chad Maven build.
    Get-ChildItem target/*-jar-with-dependencies.jar |
        ForEach-Object { Copy-Item $_ "$OutFile" -Force }

    # BlueJ expectes all package declarations to start from root.
    # Inject source code into JAR file.
    Push-Location src\main\java
    jar -uf "../../../$OutFile" *
    Pop-Location

    # Mark this as a BlueJ project.
    New-Item -ItemType file ThisIsABlueJProject
    jar -uf $OutFile ThisIsABlueJProject
    Remove-Item ThisIsABlueJProject
}

if ($Run) {
    # Ensure project has been built.
    if (-Not (Test-Path $OutFile -PathType Leaf)) {
        Write-Error "Must build project first!"
        Exit
    }

    # Remove existing BlueJ project.
    if (Test-Path $TestDirectory -PathType Container) {
        Remove-Item $TestDirectory -Recurse
    }

    # Copy exported jar
    New-Item $TestDirectory -ItemType "directory"
    Copy-Item $OutFile "$TestDirectory/out.jar"

    # Open it with BlueJ
    $Path = Resolve-Path "$TestDirectory/out.jar"
    Start-Process -NoNewWindow -FilePath $BlueJ -ArgumentList $Path -Wait

    if (-Not $NoClean) {
        # Clean up afterwards
        Remove-Item $TestDirectory -Recurse
    }
}
