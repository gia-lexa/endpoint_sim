module Api
    module V1
      class ProcessesController < ApplicationController
        
        # Allowlist executables based on the platform
        ALLOWED_EXECUTABLES = {
          'macos' => ['/bin/ls', '/bin/bash', '/usr/bin/python3', '/bin/sleep'], 
          'linux' => ['/bin/ls', '/usr/bin/echo', '/usr/bin/python3', '/bin/sleep'],
        }.freeze
  
        def create
          executable = params[:executable]
          args = params[:args] || []
  
          # Detect the platform
          platform = detect_platform

          # Add this condition to return for unsupported platforms
          return render json: { error: 'Unsupported platform' }, status: :bad_request if platform == 'unknown'
  
          # Validate that the executable is allowed for the detected platform
          unless ALLOWED_EXECUTABLES[platform].include?(executable)
            return render json: { error: 'Executable not allowed on this platform' }, status: :forbidden
          end
  
          # Spawn the process if the executable is allowed
          pid = spawn(executable, *args, out: "/dev/null", err: "/dev/null")
          Process.detach(pid)
  
          log_activity({
            timestamp: Time.now.utc.iso8601,
            username: Etc.getlogin,
            process_name: File.basename(executable),
            command_line: "#{executable} #{args.join(' ')}",
            process_id: pid
          })
  
          render json: { status: 'Process started', pid: pid }, status: :ok
        end
  
        private
  
        def log_activity(data)
          log_file = Rails.root.join('log/activity_log.json')
          File.open(log_file, 'a') { |f| f.puts(data.to_json) }
        end
  
        def detect_platform
          case RbConfig::CONFIG['host_os']
          when /darwin/
            'macos'
          when /linux/
            'linux'
          else
            'unknown'
          end
        end
      end
    end
  end
  