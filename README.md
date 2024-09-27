# README

This is a test harness, which allows you to simulate the following—process starts, file operations, and network activity, logging each action with detailed telemetry data, and exporting the logs to a machine-friendly JSON format. It’s designed to help correlate these activities with the telemetry recorded by an EDR agent.

There are three main controllers which are responsible for
triggering the relevant activity and logging the corresponding telemetry data.

ProcessesController: Starts processes with executable files and command-line arguments.
FilesController: Creates, modifies, and deletes files.
NetworkController: Simulates network connections and data transmissions.


The fourth controller, LogsController, reads logs from the created files and formats the output.
Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions


Network Controller
* Establishes network connections, sends data, logs activity

Testing Network Controller
* Simulate a destination server like netcat (nc), which can listen for TCP connections on a specific port and print out any data it receives.
    ** Whether Linux or MacOS, run this in a separate terminal tab: nc -l 443
    ** In its own terminal tab, fire up the Rails server: rails server
    ** In a third Terminal tab, run: 
        curl -X POST "http://localhost:3000/api/v1/network/connect" \
        -d "destination_address=127.0.0.1" \
        -d "destination_port=443" \
        -d "data=Greetings, Professor Falken."

    ** The netcat tab should surface:
    Hello from Rails API

    ** The Curl tab should respond with: {"status":"Data sent","bytes_sent":<integer>}

    ** Inspect the logs: cat log/activity_log.json
* ...
