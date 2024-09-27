module Api
  module V1
    class NetworkController < ApplicationController
      require 'socket' # works across MacOS and Linux
      require 'timeout'

      # POST /api/v1/network/create
      def create
        destination_address = params[:destination_address]
        destination_port = params[:destination_port]
        data_to_send = params[:data] || "Hello, World!" 

        if destination_address.nil? || destination_port.nil?
          render json: { error: 'Destination address and port are required' }, status: :bad_request and return
        end

        unless destination_port.to_s.match?(/^\d+$/)
          render json: { error: 'Invalid destination port' }, status: :bad_request and return
        end

        socket = nil  # Instantiate socket to make available later

        # Establish TCP connection
        begin
          Timeout.timeout(5) do
            socket = TCPSocket.new(destination_address, destination_port.to_i)
            socket.write(data_to_send)

            data_sent = data_to_send.bytesize
            source_address = socket.local_address.ip_address
            source_port = socket.local_address.ip_port

            log_activity({
              timestamp: Time.now.utc.iso8601,
              username: Etc.getlogin,
              destination_address: destination_address,
              destination_port: destination_port,
              source_address: source_address,
              source_port: source_port,
              data_sent: data_sent,
              protocol: "TCP",
              process_name: File.basename($PROGRAM_NAME),
              command_line: "#{$PROGRAM_NAME} #{ARGV.join(' ')}",
              process_id: Process.pid
            })

            render json: { status: 'Data sent', bytes_sent: data_sent }, status: :ok
          end
        rescue Timeout::Error
          Rails.logger.error("Connection timed out to #{destination_address}:#{destination_port}")
          render json: { error: "Connection timed out" }, status: :request_timeout
        rescue => e
          Rails.logger.error("Failed to establish connection: #{e.message}")
          render json: { error: "Failed to establish connection: #{e.message}" }, status: :bad_request
        ensure
          socket&.close if socket  # Ensure socket is closed
        end
      end

      private

      def log_activity(data)
        log_file = Rails.root.join('log/activity_log.json')
        File.open(log_file, 'a') do |f|
          f.flock(File::LOCK_EX)  # Lock the file for exclusive access
          f.puts(data.to_json)
          f.flock(File::LOCK_UN)  # Release the lock
        end
      end
    end
  end
end
