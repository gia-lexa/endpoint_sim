# EndpointSim

## Description
 This is a Rails API framework which allows you to simulate endpoint activity including process starts, file operations, and network transmissions, with each action being logged in a machine-readable format. 
 
 This data is designed to help correlate these endpoint logs with the telemetry recorded by an EDR agent in order to ensure that agent's consistent performance.

## Prerequisites
- Ruby 3.1.2 or higher
- Rails 7.1.0 or higher
- Bundler gem

## Installation
```bash
git clone https://github.com/gia-lexa/endpoint_sim.git
cd endpoint_sim
bundle install
```

## Running the Framework

Start the rails server:
`rails server`

Access the API at http://localhost:3000

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
