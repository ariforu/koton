import Foundation
import GRPC
import NIO

@MainActor
final class ClickstreamService {
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private var channel: GRPCChannel?
    private var client: ClickstreamServiceAsyncClient?

    func connect() async throws {
        // For dev use plaintext + Info.plist exception (see below)
        let channel = try GRPCChannelPool.with(
            target: .host("localhost", port: 50051),
            transportSecurity: .plaintext,
            eventLoopGroup: group
        )

        self.channel = channel
        self.client = ClickstreamServiceAsyncClient(channel: channel)
    }

    func sendClickstream(
        deviceID: String,
        eventID: String,
        eventTime: Int64,
        productID: String,
        eventType: String,
        userID: String,
        recordTime: Int64
    ) async throws -> Ack {
        guard let client else {
            try await connect()
            return try await sendClickstream(
                deviceID: deviceID,
                eventID: eventID,
                eventTime: eventTime,
                productID: productID,
                eventType: eventType,
                userID: userID,
                recordTime: recordTime
            )
        }

        // Build request
        var request = ClickstreamBronze()
        request.deviceID = deviceID
        request.eventID = eventID
        request.eventTime = eventTime
        request.productID = productID
        request.eventType = eventType
        request.userID = userID
        request.recordTime = recordTime

        // Make the call
        let ack = try await client.sendClickstream(request)
        return ack
    }

    deinit {
        try? group.syncShutdownGracefully()
    }
}

