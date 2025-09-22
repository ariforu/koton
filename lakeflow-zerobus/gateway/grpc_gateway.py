import grpc
import asyncio
from grpc import aio
import ClickstreamBronze_pb2
import ClickstreamBronze_pb2_grpc
from zerobus_sdk.aio import ZerobusSdk
from zerobus_sdk import TableProperties
import os
from dotenv import load_dotenv
import time
load_dotenv()

TABLE_NAME = os.environ["INGEST_TABLE_NAME"]
sdk_handle = ZerobusSdk(
    os.environ["ZEROBUS_HOST"],
    os.environ["DATABRICKS_WORKSPACE_URL"],
    os.environ["DATABRICKS_PAT"]
)
table_properties = TableProperties(TABLE_NAME, ClickstreamBronze_pb2.ClickstreamBronze.DESCRIPTOR)

class ClickstreamServiceServicer(ClickstreamBronze_pb2_grpc.ClickstreamServiceServicer):
    _stream = None
    async def get_stream(self):
        if self._stream is None:
            self._stream = await sdk_handle.create_stream(table_properties)
        return self._stream
    async def SendClickstream(self, request: ClickstreamBronze_pb2.ClickstreamBronze, context):
        print(f"Received Clickstream: {request}")
        request.record_time = int(time.time())
        stream = await self.get_stream()
        await stream.ingest_record(request)
        return ClickstreamBronze_pb2.Ack(success=True, message="Received")

async def serve():
    server = aio.server()
    ClickstreamBronze_pb2_grpc.add_ClickstreamServiceServicer_to_server(ClickstreamServiceServicer(), server)
    server.add_insecure_port('[::]:50051')
    await server.start()
    print("Async gRPC server started on port 50051.")
    try:
        await server.wait_for_termination()
    except KeyboardInterrupt:
        await server.stop(0)

if __name__ == "__main__":
    asyncio.run(serve())
