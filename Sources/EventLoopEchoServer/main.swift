import Foundation

let isPing = ProcessInfo.processInfo.arguments.contains("ping")
let port = isPing ? 9091 : 9090

let server = try EchoServer.connect(port: port).wait()
print("Server is up")

if isPing {
	print("Sending ping")
	try server.send(to: "127.0.0.1", port: 9090).wait()
}

try server.waitUntilClose()
