# Maven BlueJ Guide

This guide is intended for setting up an existing Maven project to create BlueJ compatible project jars.

Alternative build systems:
- [Gradle plugin for building BlueJ jars](https://github.com/KCLOSS/gradle-bluej-jar)

## Setup Guide

This is the setup guide for any machine, there is a Linux specific guide below too but I recommend using Powershell since you get more control with less fiddling around.

1. Configure Maven through `pom.xml` to allow it to export jars with dependencies.

    Add the following to your `plugins` section:

    ```xml
    <plugins>
        <plugin>
            <artifactId>maven-jar-plugin</artifactId>
            <version>3.0.2</version>
            <!-- include this section to make it executable -->
            <configuration>
                <archive>
                    <manifest>
                        <addClasspath>true</addClasspath>
                        <!-- change this to your main class -->
                        <mainClass>uk.insrt.university.bluej.App</mainClass>
                    </manifest>
                </archive>
            </configuration>
        </plugin>
        <!-- this section is required to export correctly -->
        <plugin>
            <artifactId>maven-assembly-plugin</artifactId>
            <configuration>
                <archive>
                    <manifest>
                        <!-- change this to your main class -->
                        <mainClass>uk.insrt.university.bluej.App</mainClass>
                    </manifest>
                </archive>
                <descriptorRefs>
                    <descriptorRef>jar-with-dependencies</descriptorRef>
                </descriptorRefs>
            </configuration>
            <executions>
                <execution>
                    <id>make-assembly</id>
                    <phase>package</phase>
                    <goals>
                        <goal>single</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
    ```

    **Note**: You may already have the `maven-jar-plugin` plugin installed, simply replace it or add the extra configuration as above to make it executable.

2. If you haven't already, make sure Maven is in your PATH, verify this by running `mvn`.

    Refer to [Windows prerequisites](https://maven.apache.org/guides/getting-started/windows-prerequisites.html) for instructions. You can [download Maven itself here](https://maven.apache.org/download.cgi) if you haven't already and are just running it through your IDE.

3. Download [BlueJ.ps1](https://raw.githubusercontent.com/KCLOSS/maven-bluej/master/BlueJ.ps1) and place it in the root of your project.
4. Export your project for BlueJ.

    ```powershell
    ./BlueJ.ps1 -Build
    ```

5. If this fails and you are on Windows, you may need to [enable script execution](https://superuser.com/a/106363).
6. Optionally, open it in BlueJ to print or view class diagram.

    ```powershell
    ./BlueJ.ps1 -Run
    # You may also include -Build to build before running.
    ```

    By default, `-Path` is configured for the default Windows installation path, if you are for example on Arch Linux, you should set it as follows:

    ```powershell
    ./BlueJ.ps1 -Run -Path bluej
    ```

### Parameters

The Powershell script has several parameters you may specify:

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `Build` | Switch | Set to tell the script to build the BlueJ jar. | false |
| `Run` | Switch | Set to tell the script to run BlueJ with the jar. | false |
| `NoClean` | Switch | Will not destroy test directory after closing BlueJ. | false |
| `BlueJ` | String | Path to BlueJ executable. | `C:/Program Files/BlueJ/BlueJ.exe` |
| `TestDirectory` | String | Directory to -Run the project in. | `test` |
| `OutFile` | String | Where to export the BlueJ jar. | `target/bluej_out.jar` |
| `BuildCommand` | String | Build command to produce jar with dependencies. | `mvn clean compile assembly:single` |

## Notes

- You do not need to do any additional work to configure BlueJ, each time it's imported, BlueJ performs a final conversion and creates the `package.bluej` files that are missing.
- Class diagrams need to be manually created and added to your source files, for example, run `./BlueJ.sh -Run -NoClean`, organise your class diagrams then exit out. Copy over any meaningful `package.bluej` files into your source code, these will be bundled as such when you export.
- You **do not** need to bundle any extra dependencies manually, e.g. adding to the `+jars` folder like in BlueJ, you can simply pull them in through Maven.

    Dependencies are exported in the JAR alongside your source and classes, BlueJ can discover these just fine and it is unnecessary to include the dependencies twice.

## Setup Guide (Linux)

This is the setup guide for Linux machines with Bash.

1. Include plugin in `pom.xml` as stated in the main setup guide.
2. Download [bluej.sh](https://raw.githubusercontent.com/KCLOSS/maven-bluej/master/bluej.sh) and place it in the root of your project.
3. Give the file permissions to execute.

    ```bash
    chmod +x bluej.sh
    ```

4. Export your project for BlueJ.

    ```bash
    ./bluej.sh build
    ```

5. Optionally, open it in BlueJ to print or view class diagram.

    ```bash
    ./bluej.sh run
    ```

    You can also chain commands together:

    ```bash
    ./bluej.sh build run
    ```
