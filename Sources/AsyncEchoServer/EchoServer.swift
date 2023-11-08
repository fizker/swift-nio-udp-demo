import NIO

class EchoServer {
	var channel: Channel

	public init(port: Int) async throws {
		let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
		let bootstrap = DatagramBootstrap(group: group)
			.channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
			.channelInitializer {
				$0.pipeline.addHandler(EchoHandler())
			}

		channel = try await bootstrap.bind(host: "0.0.0.0", port: port).get()
	}

	public func send(to ip: String, port: Int) async throws {
		try await send(to: .init(ipAddress: ip, port: port))
	}

	public func send(to remoteAddress: SocketAddress) async throws {
		let buffer = ByteBuffer(string: "ping")
		let envelope = AddressedEnvelope(remoteAddress: remoteAddress, data: buffer)
		try await channel.writeAndFlush(envelope)
	}

	public func waitUntilClose() async throws {
		try await channel.closeFuture.get()
	}

	class EchoHandler: ChannelInboundHandler {
		typealias InboundIn = AddressedEnvelope<ByteBuffer>
		typealias OutboundOut = AddressedEnvelope<ByteBuffer>

		func channelRead(context: ChannelHandlerContext, data: NIOAny) {
			let input = unwrapInboundIn(data)
			var inputData = input.data
			let value = inputData.readString(length: input.data.readableBytes)

			print("Received message from \(input.remoteAddress)")
			print("Message is: \(String(describing: value))")

			if value == "ping" {
				let data = ByteBuffer(string: "pong")
				let output = AddressedEnvelope(remoteAddress: input.remoteAddress, data: data)
				context.write(wrapOutboundOut(output) , promise: nil)
			} else if value == "pong" {
				_ = context.close()
			} else {
				context.fireChannelRead(data)
			}
		}

		func channelReadComplete(context: ChannelHandlerContext) {
			context.flush()
		}

		func errorCaught(context: ChannelHandlerContext, error: Error) {
			print("error: \(error)")
			context.close(promise: nil)
		}
	}
}
