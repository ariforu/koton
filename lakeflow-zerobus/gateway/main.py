import asyncio
import ClickstreamBronze_pb2 as bronze # This is the compiled proto definition from step 3.
from zerobus_sdk.aio import ZerobusSdk
from zerobus_sdk import TableProperties

import os

from dotenv import load_dotenv

load_dotenv()

TABLE_NAME = os.environ["INGEST_TABLE_NAME"]
sdk_handle = ZerobusSdk(
    os.environ["ZEROBUS_HOST"],
    os.environ["DATABRICKS_WORKSPACE_URL"],
    os.environ["DATABRICKS_PAT"]
)

table_properties = TableProperties(TABLE_NAME, bronze.ClickstreamBronze.DESCRIPTOR)



async def example():
    # Create stream to table.
    stream = await sdk_handle.create_stream(table_properties)
    
    # non-blocking (streaming) call.
    NUM_RECORDS = 10
    import time
    for i in range(NUM_RECORDS):
        current_epoch_long = int(time.time())
        # we are awaiting it to be queued
        await stream.ingest_record(bronze.ClickstreamBronze(
            device_id="device_id",
            event_id="event_id",
            event_time=current_epoch_long,
            product_id="product_id",
            event_type="event_type",
            user_id="alan.john",
            record_time=current_epoch_long
        ))

    # Wait until we receive the ack for the latest record
    await stream.flush()

    # Close the stream
    await stream.close()

if __name__ == "__main__":
    asyncio.run(example())


#