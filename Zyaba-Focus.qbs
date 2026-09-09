import qbs

CppApplication {
    name: "Zyaba-Focus"

    Depends { name: "Qt.core" }
    Depends { name: "Qt.gui" }
    Depends { name: "Qt.quick" }
    Depends { name: "Qt.gui-private" }

    cpp.cxxLanguageVersion: "c++11"
    cpp.warningLevel: "all"

    files: [
	"gamemanager.cpp",
	"gamemanager.h",
	"j2meview.cpp",
	"j2meview.h",
	"main.cpp",
	"qml.qrc",
	"retrohost.cpp",
	"retrohost.h",
    ]

    //--- INICIO DE PROJECT D'APPLICACIO ---
    Group {
	name: "The App itself"
	fileTagsFilter: "application"
	qbs.install: true
	qbs.installDir: "."
    }

    // Windows JRE
    Group {
	name: "Windows Java Runtime Environment"
	condition: qbs.targetOS.contains("windows")
	files: "Windows_JVM/jre/**"
	qbs.install: true
	qbs.installSourceBase: "Windows_JVM"
	qbs.installDir: "."
    }

    // --- LINUX JRE: Разделение по архитектурам ---

    // 1. ARM 32-bit (armhf)
    Group {
	name: "Linux JRE (ARM32 - armhf)"
	condition: qbs.targetOS.contains("linux") && (qbs.architecture === "arm" || qbs.architecture === "armhf" || qbs.architecture === "armv7a" || qbs.architecture === "armv7l")
	files: "Linux_JVM/armhf/**"
	qbs.install: true
	qbs.installSourceBase: "Linux_JVM/armhf"
	qbs.installDir: "jre"
    }

    // 2. ARM 64-bit (arm64 / aarch64)
    Group {
	name: "Linux JRE (ARM64 - aarch64)"
	condition: qbs.targetOS.contains("linux") && (qbs.architecture === "arm64" || qbs.architecture === "aarch64")
	files: "Linux_JVM/arm64/**"
	qbs.install: true
	qbs.installSourceBase: "Linux_JVM/arm64"
	qbs.installDir: "jre"
    }

    // 3. x86_64 / amd64
    Group {
	name: "Linux JRE (AMD64 - x86_64)"
	condition: qbs.targetOS.contains("linux") && (qbs.architecture === "x86_64" || qbs.architecture === "amd64")
	files: "Linux_JVM/amd64/**"
	qbs.install: true
	qbs.installSourceBase: "Linux_JVM/amd64"
	qbs.installDir: "jre"
    }

    Properties {
	condition: qbs.targetOS.contains("windows")
	cpp.dynamicLibraries: ["user32"]
    }

    Properties {
	condition: qbs.targetOS.contains("linux")
	cpp.dynamicLibraries: ["dl"]
    }

    Group {
	name: "QML Files"
	files: ["*.qml", "*.js"]
	qbs.install: true
    }

    Group {
	name: "Ubuntu Touch Metadata"
	files: ["*.desktop", "*.apparmor", "manifest.json", "Zyaba-Splash.svg", "Zyaba-Logo.svg"]
	qbs.install: true
    }

    Group {
	name: "Zyaba User Interface Tool-kit"
	qbs.install: true
	qbs.installDir: "ZyabaUI"
	files: ["ZyabaUI/Icons/*.svg", "ZyabaUI/*.qml"]
    }

    Group {
	name: "FreeJ2ME+ Core"
	qbs.install: true
	qbs.installDir: "."
	files: "freej2me.jar"
    }
}
