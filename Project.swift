import ProjectDescription

let project = Project(
    name: "Untwist",
    settings: .settings(
        base: [
            "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
            "INFOPLIST_KEY_CFBundleDisplayName": "Untwist",
            "DEVELOPMENT_TEAM": "UJ8692CVFW"  // John Pacheco (Personal Team)
        ]
    ),
    targets: [
        .target(
            name: "Untwist",
            destinations: .iOS,
            product: .app,
            bundleId: "com.johnpacheco.Untwist",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleGetInfoString": "",
                "FEEDBACK_API_KEY": "$(FEEDBACK_API_KEY)",
                "NSFaceIDUsageDescription": "Untwist uses Face ID to protect your private thoughts and mental health data.",
                "NSUserNotificationsUsageDescription": "Untwist can send you optional daily reminders for your scheduled worry time to help you build a consistent practice.",
                "UILaunchScreen": [:],  // Modern launch screen (iOS 14+)
                "UIRequiresFullScreen": false  // Supports all device sizes
            ]),
            sources: ["Untwist/**/*.swift"],
            resources: [
                "Untwist/**/*.xcassets",
                "Untwist/**/*.xib",
                "Untwist/**/*.storyboard",
                "Untwist/**/*.strings"
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
            name: "UntwistTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.johnpacheco.UntwistTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["UntwistTests/**/*.swift"],
            dependencies: [
                .target(name: "Untwist")
            ]
        ),
        .target(
            name: "UntwistUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.johnpacheco.UntwistUITests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["UntwistUITests/**/*.swift"],
            dependencies: [
                .target(name: "Untwist")
            ]
        )
    ]
)
