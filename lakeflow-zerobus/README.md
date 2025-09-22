
# Lakeflow ZeroBus

## Overview

Lakeflow ZeroBus is a gRPC based event streaming service that allows you to stream events directly to a Databricks Delta table.

## Prerequisites

- Python 3.9
- xcode
## Installation

Install the Zerobus SDK.This SDK is available in the private preview and not distributed via PyPI or from this repository. Please contact your Databricks  representative to get access to the private preview.

```bash
pip install ./gateway/databricks_zerobus-0.0.16-py3-none-any.whl
```

Set the environment variables
```bash
export DATABRICKS_WORKSPACE_URL=<your workspace url>
export DATABRICKS_PAT=<your workspace pat>
export INGEST_TABLE_NAME=arijit.psa.clickstream_bronze
export INGEST_PROTO_MSG=<your proto message name>
export ZEROBUS_HOST=<your zerobus ingestion host>
```

Generate the proto file from the table schema
```bash
generate_proto --uc-endpoint $DATABRICKS_WORKSPACE_URL --uc-token $DATABRICKS_PAT --table arijit.psa.clickstream_bronze --output ClickstreamBronze.proto
vi ClickstreamBronze.proto
```

Update the proto file and add the service definition and the return message definition (ack). It should look like this

```proto
syntax = "proto2";

message ClickstreamBronze {
    required string event_id = 1;
    required string event_name = 2;
    required string event_timestamp = 3;
    required string event_type = 4;
    required string event_source = 5;
    required string event_version = 6;
    required string event_data = 7;
}

message Ack {
    required string event_id = 1;
    required string status = 2;
    required string message = 3;
}

service ClickstreamService {
    rpc SendClickstream (ClickstreamBronze) returns (Ack);
}
```

Generate the python stubs including the gRPC service stubs from the proto file
```bash
python3 -m grpc_tools.protoc -I. --python_out=./gateway --grpc_python_out=./gateway ClickstreamBronze.proto
```
Similarly generate the swift stubs.
```bash
python3 -m grpc_tools.protoc -I. \
  ClickstreamBronze.proto \
  --swift_out=ios-app/ZerobusTest/Protos \
  --grpc-swift_out=ios-app/ZerobusTest/Protos \
  --grpc-swift_opt=Client=true,Server=false
```

`grpc_gateway.py` has the Gateway server implementation. It uses the gRPC service stubs to stream the events to the Databricks Delta table using the ZeroBus SDK.

Run the gateway server
```bash
python3 gateway/grpc_gateway.py
```


