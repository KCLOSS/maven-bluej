#!/bin/bash
# Maven to BlueJ helper script
# Author: Pawel Makles <https://insrt.uk>
# Repository: https://github.com/KCLOSS/maven-bluej
# Version: 0.1

# Usage:
# ./bluej.sh <action> [...action]
#
# Actions:
# - build
# - run
#
# Example Usage:
# ./bluej.sh build run

BLUEJ="bluej"
TEST_DIRECTORY="test"
OUT="target/bluej_out.jar"
BUILD="mvn clean compile assembly:single"

for arg in "$@"
do
    if [ "$arg" = "build" ]; then
        # Build Maven project.
        $BUILD;

        # Copy the chad Maven build.
        for file in target/*-jar-with-dependencies.jar;
            do cp "$file" "$OUT";
        done;

        # BlueJ expects all package declarations to start from root. (lol)
        # Inject source code into JAR file.
        pushd src/main/java;
        zip -ur "../../../$OUT" *;
        popd;

        # Mark this as a BlueJ project.
        # Use resource loader to detect during runtime.
        touch ThisIsABlueJProject;
        zip -u $OUT ThisIsABlueJProject;
        rm ThisIsABlueJProject;
    elif [ "$arg" = "run" ]; then
        # Ensure project has been built.
        if ! test -f "target/bluej_out.jar"; then
            echo "Must build project first!";
            exit;
        fi;

        # Remove existing BlueJ project.
        rm -rf $TEST_DIRECTORY;

        # Copy exported jar
        mkdir $TEST_DIRECTORY;
        cp target/bluej_out.jar $TEST_DIRECTORY/out.jar;

        # Open it with BlueJ.
        bluej "$(realpath $TEST_DIRECTORY/out.jar)";

        # Clean up.
        rm -rf $TEST_DIRECTORY;
    else
        echo "Unknown action $arg!";
    fi
done
