import ProjectDescription

let project = Project(
    name: "Execute",
    targets: [
        Target(
            name: "Execute",
            platform: .macOS,
            product: .framework,
            bundleId: "com.swiftcli.execute",
            infoPlist: "Info.plist",
            sources: "Sources/Execute/**"
        )
    ]
)
