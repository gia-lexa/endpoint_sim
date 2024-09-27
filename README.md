# EndpointSim

## Description
This is a test harness for telemetry data. This is a Rails API framework which allows you to simulate process starts, file operations, and network activity, logging each action in a machine-readable format. It’s designed to help correlate these endpoint logs with the telemetry recorded by an EDR agent.

The central actions take place in the app's controllers, which can work across Linux and macOS platforms.

-ProcessesController: Starts processes with executable files and command-line arguments.
-FilesController: Creates, modifies, and deletes files.
-NetworkController: Simulates network connections and data transmissions.
-LogsController: Fetches and optionally filters the logs.

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

# Testing

Each controller includes a spec file, which uses RSpec to test its behavior in a broader context, including validatng the full HTTP response cycle.

Run a single test:
`bundle exec rspec <path/to/spec_file.rb>`

Run the test suite:
`bundle exec rspec`


