package uk.insrt.coursework.zuul.util;

import java.lang.reflect.Field;
import java.net.URLClassLoader;
import java.util.Vector;

/**
 * Utilities for detecting we are running in BlueJ.
 * 
 * @author Paul Makles <https://insrt.uk>
 * @version 2.0
 */
public class BlueJ {
    /**
     * Whether to ignore deprecation warnings.
     * Enable to allow isRunningInBlueJ() to confidently determine status.
     */
    private static boolean liveOnTheEdge = false;

    /**
     * Check whether this is being exported as BlueJ using maven-bluej
     * https://github.com/KCLOSS/maven-bluej
     * @return Whether this was exported as a BlueJ project.
     */
    public static boolean isExportedAsBlueJ() {
        return BlueJ.class.getResource("/ThisIsABlueJProject") != null;
    }

    /**
     * Detect whether we are currently running under BlueJ.
     * @return Whether we are running from BlueJ.
     */
    public static boolean isRunningInBlueJ() {
        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();

        // When we load the project typically, i.e. from a JAR file, it is instead
        // loaded by jdk.internal.loader.ClassLoaders$PlatformClassLoader and then
        // $AppClassLoader, which we should also see further up the chain from the
        // java.net.URLClassLoader loader.
        if (classLoader instanceof URLClassLoader) {
            if (getJavaVersion() > 8 && !liveOnTheEdge) {
                // Using setAccessible() as below is deprecated in Java 9 onwards,
                // so to avoid any errors in stderr, we can take a safe bet and
                // assume that we are in BlueJ given the way we are being loaded.
                return true;
            }

            // We can verify we are running under BlueJ by looping through all
            // classes which exist on the parent class loader and to check if
            // a BlueJ class is present.
            try {
                // Finding classes loaded by ClassLoader.
                // https://stackoverflow.com/a/10261850
                Field f = ClassLoader.class.getDeclaredField("classes");
                f.setAccessible(true);

                @SuppressWarnings("unchecked")
                Vector<Class<?>> classes = (Vector<Class<?>>) f.get(classLoader.getParent());

                for (Class<?> cls : classes) {
                    if (cls.getName().startsWith("bluej.runtime")) {
                        return true;
                    }
                }
            } catch(NoSuchFieldException | IllegalAccessException | ClassCastException e) {}
        }

        return false;
    }

    /**
     * Gets the current Java version as a single integer.
     * Taken from https://stackoverflow.com/a/2591122
     * @return Current Java major version number.
     */
    private static int getJavaVersion() {
        String version = System.getProperty("java.version");
        return Integer.parseInt(
            version.startsWith("1.")
                ? version.substring(2, 3)
                : (
                    version.indexOf(".") != -1
                        ? version.substring(0, version.indexOf("."))
                        : version
                )
        );
    }
}
