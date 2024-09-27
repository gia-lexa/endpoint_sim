module Api
    module V1
      class FilesController < ApplicationController
  
        # POST /api/v1/files/create
        def create
          file_path = params[:file_path]
          content = params[:content] || "Default content"
  
          if file_path.nil? || file_path.empty?
            render json: { error: 'File path is missing' }, status: :bad_request and return
          end
  
          begin
            File.open(file_path, 'w') { |file| file.write(content) }
  
            log_file_activity(file_path, 'create')
  
            render json: { status: 'File created', path: file_path }, status: :ok
          rescue => e
            render json: { error: 'Failed to create file', message: e.message }, status: :internal_server_error
          end
        end
  
        # PATCH /api/v1/files/update
        def update
          file_path = params[:file_path]
          new_content = params[:new_content] || "Updated content"
  
          if file_path.nil? || file_path.empty?
            render json: { error: 'File path is missing' }, status: :bad_request and return
          end
  
          unless File.exist?(file_path)
            render json: { error: 'File not found', path: file_path }, status: :not_found and return
          end
  
          begin
            File.open(file_path, 'w') { |file| file.write(new_content) }
  
            log_file_activity(file_path, 'update')
  
            render json: { status: 'File updated', path: file_path }, status: :ok
          rescue => e
            render json: { error: 'Failed to update file', message: e.message }, status: :internal_server_error
          end
        end
  
        # DELETE /api/v1/files/destroy
        def destroy
          file_path = params[:file_path]
  
          if file_path.nil? || file_path.empty?
            render json: { error: 'File path is missing' }, status: :bad_request and return
          end
  
          unless File.exist?(file_path)
            render json: { error: 'File not found', path: file_path }, status: :not_found and return
          end
  
          begin
            File.delete(file_path)
  
            log_file_activity(file_path, 'delete')
  
            render json: { status: 'File deleted', path: file_path }, status: :ok
          rescue => e
            render json: { error: 'Failed to delete file', message: e.message }, status: :internal_server_error
          end
        end

        private
  
        def log_file_activity(file_path, activity)
          log_data = {
            timestamp: Time.now.utc.iso8601,
            full_path: file_path,
            activity: activity,
            username: Etc.getlogin,
            process_name: $0,
            command_line: ARGV.join(' '),  # Add command-line logging
            process_id: Process.pid
          }
  
          log_file = Rails.root.join('log/activity_log.json')
          # Open the log file with write access,lock using 'flock'
          File.open(log_file, 'a') do |f|
            f.flock(File::LOCK_EX)  # Apply exclusive lock (waits if another process holds the lock)
            f.puts(log_data.to_json)  # Write the log data
            f.flock(File::LOCK_UN)  # Release lock
          end
        end
      end
    end
  end
  