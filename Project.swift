import ProjectDescription

let project = Project(
    name: "Monitor",
    settings: .settings(
        base: [
            "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
            "INFOPLIST_KEY_CFBundleDisplayName": "Monitor",
            "DEVELOPMENT_TEAM": "UJ8692CVFW",  // John Pacheco (Personal Team)
            "MARKETING_VERSION": "1.0",
            "CURRENT_PROJECT_VERSION": "9"
        ]
    ),
    targets: [
        .target(
            name: "Monitor",
            destinations: .iOS,
            product: .app,
            bundleId: "com.johnpacheco.Monitor",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleGetInfoString": "",
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                "FEEDBACK_API_KEY": "$(FEEDBACK_API_KEY)",
                "ITSAppUsesNonExemptEncryption": false,  // No custom encryption beyond iOS standard
                "NSCameraUsageDescription": "Monitor needs camera access to take photos of your meals for your personal recovery journal.",
                "NSFaceIDUsageDescription": "Monitor uses Face ID to protect your private thoughts and mental health data.",
                "NSPhotoLibraryUsageDescription": "Monitor needs photo library access to select photos of your meals for your personal recovery journal.",
                "NSUserNotificationsUsageDescription": "Monitor can send you optional daily reminders for your scheduled worry time to help you build a consistent practice.",
                "UILaunchScreen": [
                    "UIColorName": "",
                    "UIImageRespectsSafeAreaInsets": true
                ],
                "UIRequiresFullScreen": false  // Supports all device sizes
            ]),
            sources: ["Monitor/**/*.swift"],
            resources: [
                "Monitor/**/*.xcassets",
                "Monitor/**/*.xib",
                "Monitor/**/*.storyboard",
                "Monitor/**/*.strings"
            ],
            dependencies: [],
            settings: .settings(
                configurations: [
                    // Debug configuration - Signing enabled for all targets
                    // (Simulator builds don't actually sign, device builds do)
                    .debug(
                        name: "Debug",
                        settings: [
                            "CODE_SIGN_STYLE": "Automatic",
                            "CODE_SIGN_IDENTITY": "Apple Development",
                            "DEVELOPMENT_TEAM": "UJ8692CVFW"  // John Pacheco (Personal Team)
                        ]
                    ),
                    // Release configuration - Automatic signing for device builds
                    .release(
                        name: "Release",
                        settings: [
                            "CODE_SIGN_STYLE": "Automatic",
                            "CODE_SIGN_IDENTITY": "Apple Development",
                            "DEVELOPMENT_TEAM": "UJ8692CVFW"  // John Pacheco (Personal Team)
                        ]
                    )
                ]
            )
        ),
        .target(
            name: "MonitorTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.johnpacheco.MonitorTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["MonitorTests/**/*.swift"],
            dependencies: [
                .target(name: "Monitor")
            ]
        ),
        .target(
            name: "MonitorUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.johnpacheco.MonitorUITests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["MonitorUITests/**/*.swift"],
            dependencies: [
                .target(name: "Monitor")
            ]
        )
    ]
)
