import Foundation

if ProcessInfo.processInfo.arguments.contains("ping") {
	let server = try await EchoServer(port: 9091)
	try await server.send(to: "127.0.0.1", port: 9090)
	try await server.waitUntilClose()
} else {
	let server = try await EchoServer(port: 9090)
	try await server.waitUntilClose()
}
