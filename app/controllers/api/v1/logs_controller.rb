module Api
    module V1
      class LogsController < ApplicationController

        # GET /api/v1/logs
        def index
          log_file_path = Rails.root.join('log/activity_log.json')
          
          if File.exist?(log_file_path)
            logs = read_logs(log_file_path)

            # Filters logs if the 'type' query parameter is present
            logs = logs.select { |log| log['type'] == params[:type] } if params[:type].present?
            render json: logs, status: :ok
          else
            render json: { error: 'Log file not found' }, status: :not_found
          end
        end
  
        private
  
        # Reads from log file and parses as JSON
        def read_logs(log_file_path)
          logs = []
          File.foreach(log_file_path) do |line|
            logs << JSON.parse(line)
          end
          logs
        end
      end
    end
  end
  