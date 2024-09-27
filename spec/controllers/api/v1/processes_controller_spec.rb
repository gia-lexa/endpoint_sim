require 'rails_helper'

RSpec.describe Api::V1::ProcessesController, type: :controller do
  let(:valid_linux_executable) { '/bin/ls' }
  let(:valid_macos_executable) { '/usr/bin/echo' }
  let(:invalid_executable) { '/bin/unknown_command' }
  let(:log_file_path) { Rails.root.join('log/activity_log.json') }

  before do
    File.open(log_file_path, 'w') { |f| f.truncate(0) }
    allow(Etc).to receive(:getlogin).and_return('test_user')
    allow(Process).to receive(:spawn).with(any_args).and_return(12345)
    allow(Process).to receive(:detach)                    # Global mock for detach
  end

  # Valid process creation on Linux
  context 'when on Linux' do
    before do
      allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('linux')
      allow(Process).to receive(:spawn).and_return(12345)  # Mock spawn for any args
      allow(Process).to receive(:detach)
    end
  
    it 'allows valid executable' do
      post :create, params: { executable: valid_linux_executable, args: ['-l'] }, as: :json
    
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['status']).to eq('Process started')
    end
  end 

    # Valid process creation macOS
    context 'when on macOS' do
      let(:valid_macos_executable) { '/bin/bash' }
      before do
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('darwin')
      
        # Mock any call to Process.spawn regardless of arguments to return a consistent PID
        allow(Process).to receive(:spawn).and_return(31407)  # Match the actual PID in the test output
        allow(Process).to receive(:detach)
      end
    
      it 'allows valid executable' do
        post :create, params: { executable: valid_macos_executable, args: ['-c', 'echo Hello, World!'] }, as: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('Process started')
        expect(JSON.parse(response.body)).to have_key('pid')  # Check that 'pid' exists, but not its exact value
      end
    end

    # Invalid executable
    context 'when executable is not allowed' do
      before do
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('linux')
      end

      it 'returns forbidden status' do
        post :create, params: { executable: invalid_executable, args: [] }

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)['error']).to eq('Executable not allowed on this platform')
      end
    end

    # Process creation with no arguments
    context 'when no arguments are passed' do
      before do
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('linux')
        allow(Process).to receive(:spawn).and_return(23456)
        allow(Process).to receive(:detach)
      end

      it 'runs the process without arguments' do
        post :create, params: { executable: valid_linux_executable }, as: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('Process started')
        expect(JSON.parse(response.body)).to have_key('pid')
      end
    end

    # Platform detection
    describe '#detect_platform' do
      it 'returns macos when on macOS' do
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('darwin')
        expect(controller.send(:detect_platform)).to eq('macos')
      end

      it 'returns linux when on Linux' do
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('linux')
        expect(controller.send(:detect_platform)).to eq('linux')
      end

      it 'returns unknown for unsupported platform' do
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('unsupported_os')
        expect(controller.send(:detect_platform)).to eq('unknown')
      end
    end

    # Unsupported platform
    context 'when platform is unsupported' do
      before do
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('unsupported_os')
      end

      it 'returns bad request' do
        post :create, params: { executable: valid_linux_executable }, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('Unsupported platform')
      end
    end

    # 7. Logging behavior
    context 'when process is started successfully' do
      before do
        allow(RbConfig::CONFIG).to receive(:[]).with('host_os').and_return('linux')
        allow(Etc).to receive(:getlogin).and_return('test_user')
        allow(Process).to receive(:spawn).and_return(34567)
        allow(Process).to receive(:detach)
        allow(File).to receive(:open).with(log_file_path, 'a').and_call_original
      end

      it 'logs the process activity to a file' do

        post :create, params: { executable: valid_linux_executable, args: ['-l', '/'] }, as: :json
      
        expect(File).to have_received(:open).with(log_file_path, 'a').at_least(:once)
      
        # Read the first line from the log file
        first_log = File.readlines(log_file_path).map(&:strip).reject(&:empty?).first
        log_data = JSON.parse(first_log)
      
        # Check individual key values in the first logged data
        expect(log_data['username']).to eq('test_user')
        expect(log_data['process_name']).to eq('ls')
        expect(log_data['command_line']).to eq('/bin/ls -l /')
        expect(log_data).to have_key('timestamp')  # Ensure timestamp exists
      end
    end # context
end
