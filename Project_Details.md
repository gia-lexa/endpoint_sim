# Description
EndpointSim is a test harness framework, designed to simulate endpoint activity across macOS and Linux platforms. It enables users to generate various telemetry data such as process starts, file management, and network transmissions. This data can then be used to validate EDR agent performance.

# What I'll Do Differently Next Time
Though it's not a hinderance, I find the choice of Rails, while convenient, is too heavyweight for what this accomplishes. Either Sinatra or a Ruby CLI could have sufficed here. 

# How it Works

## Controllers
The main actions of the framework are contained in four Rails controllers. Process, Files, and Network controllers log their activity in machine-readable json. The Logs Controller extracts those logs, either filtered or en masse.

## ProcessController
Given a path to an executable file and the desired command-line arguments, uses the Ruby method `spawn` to start a process.
Can utilize executables from either macOS or Linux.

## FilesController
Creates, modifies, and deletes a specified file, based on the file_path parameter provided in the API request.

## NetworkController
Establishes a network connection, via TCP, and transmits data. That connection is made with TCPSocket which is platform-independent.

## LogsController 
Programmatically retrieves and returns log entries. Can filter by type.

# Routing
The application uses RESTful routing to map HTTP requests to controller actions. For example, a POST request to /api/v1/processes triggers the create action in the ProcessesController.

# Testing
Each controller includes a spec file, which uses RSpec to test its behavior in a broad context, including how it interacts with the file system.

The tests validate the full HTTP response cycle, from the request to the response, ensuring that the controller correctly handles various scenarios related to the log file.

# Simulating Endpoint Activity
Users can trigger activities using cURL commands, sending JSON data to specific endpoints. The framework logs all activities, which can then be used as a baseline for EDR agent functionality both before and after that agent has been updated.

# Expected Outcomes
The project provides feedback through JSON responses, indicating the success or failure of the requested actions.

