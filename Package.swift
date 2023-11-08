// swift-tools-version: 5.9

import PackageDescription

let package = Package(
	name: "swift-nio-udp-demo",
	platforms: [
		.macOS(.v10_15),
	],
	products: [
		.executable(
			name: "async-echo-server",
			targets: ["AsyncEchoServer"]
		),
		.executable(
			name: "event-loop-echo-server",
			targets: ["EventLoopEchoServer"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-nio.git", from: "2.59.0"),
	],
	targets: [
		.executableTarget(
			name: "AsyncEchoServer",
			dependencies: [
				.product(name: "NIO", package: "swift-nio"),
			]
		),
		.executableTarget(
			name: "EventLoopEchoServer",
			dependencies: [
				.product(name: "NIO", package: "swift-nio"),
			]
		),
	]
)
