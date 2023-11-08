import Foundation

let isPing = ProcessInfo.processInfo.arguments.contains("ping")
let port = isPing ? 9091 : 9090

let server = try await EchoServer(port: port)
print("Server is up")

if isPing {
	print("Sending ping")
	try await server.send(to: "127.0.0.1", port: 9090)
}

try await server.waitUntilClose()
