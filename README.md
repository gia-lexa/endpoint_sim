# EndpointSim

## Summary
EndpointSim is a Rails API test harness framework, designed to simulate endpoint activity across macOS and Linux platforms. It enables users to generate various telemetry data such as process starts, file management, and network transmissions. This data could ostensibly be used to validate EDR agent performance.


## Tests

Each controller includes a spec file, which uses RSpec to test its behavior in a broader context, including validatng the full HTTP response cycle.

Run a single test:
`bundle exec rspec <path/to/spec_file.rb>`

Run the test suite:
`bundle exec rspec`

## Simulation Examples

### Create a File
```
curl -X POST http://localhost:3000/api/v1/files \
-H "Content-Type: application/json" \
-d '{"file_path": "/tmp/test_file.txt", "content": "test file data"}'
```

### Start a Process (with a macOS executable)
```
curl -X POST http://localhost:3000/api/v1/processes \
-H "Content-Type: application/json" \
-d '{"executable": "/bin/ls", "args": ["Hello World"]}'
```
             
### Send Network Transmission
```
curl -X POST http://localhost:3000/api/v1/network \
-H "Content-Type: application/json" \
-d '{"destination_address": "localhost", "destination_port": 3000, "data": "Greetings, Professor Falken."}'
```

Disclaimer
This project is an in-progress technical demonstration of a personal use test harness. While provided under the MIT License, it is not optimized for production use, and no guarantees are made regarding security, reliability, or real-world performance. It serves as an exploration of best practices in test harness development.

