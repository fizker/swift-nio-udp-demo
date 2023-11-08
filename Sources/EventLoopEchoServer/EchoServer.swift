import NIO

class EchoServer {
	var channel: Channel

	init(channel: Channel) {
		self.channel = channel
	}

	public static func connect(port: Int) -> EventLoopFuture<EchoServer> {
		let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
		let bootstrap = DatagramBootstrap(group: group)
			.channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
			.channelInitializer {
				$0.pipeline.addHandler(EchoHandler())
			}

		return bootstrap.bind(host: "0.0.0.0", port: port)
			.map(EchoServer.init)
	}

	public func send(to ip: String, port: Int) throws -> EventLoopFuture<Void> {
		try send(to: .init(ipAddress: ip, port: port))
	}

	public func send(to remoteAddress: SocketAddress) -> EventLoopFuture<Void> {
		let buffer = ByteBuffer(string: "ping")
		let envelope = AddressedEnvelope(remoteAddress: remoteAddress, data: buffer)
		let promise: EventLoopPromise<Void> = channel.eventLoop.makePromise()
		channel.writeAndFlush(envelope, promise: promise)
		return promise.futureResult
	}

	public func waitUntilClose() throws {
		try channel.closeFuture.wait()
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
