require 'rails_helper'

RSpec.describe Api::V1::NetworkController, type: :controller do
  let(:destination_address) { 'localhost' }
  let(:destination_port) { 8080 } # Use a port that is likely to be open on localhost
  let(:log_file_path) { Rails.root.join('log', 'activity_log.json') }

  before(:each) do
    # Clear the log file before each test
    File.truncate(log_file_path, 0) if File.exist?(log_file_path)
  end

  describe 'POST #create' do
    context 'when the network request is successful' do
      before do
        # Mock TCPSocket to avoid making an actual network connection
        mock_socket = instance_double(TCPSocket)
        allow(TCPSocket).to receive(:new).and_return(mock_socket)
        allow(mock_socket).to receive(:write)
        allow(mock_socket).to receive(:local_address).and_return(Addrinfo.tcp('localhost', 8080))
        allow(mock_socket).to receive(:close)
      end

      it 'sends data and logs the activity' do
        post :create, params: { destination_address: destination_address, destination_port: destination_port, data: 'Test data' }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('Data sent')

        # Check if the log file contains the correct entry
        log_content = File.read(log_file_path)
        log_json = JSON.parse(log_content)

        expect(log_json).to include(
          'timestamp',
          'username' => Etc.getlogin,
          'destination_address' => destination_address,
          'destination_port' => destination_port.to_s,
          'source_address' => '::1',
          'source_port' => 8080,
          'data_sent' => 9,
          'protocol' => 'TCP',
          'process_name' => 'rspec',
          'command_line' => /rspec/
        )
        expect(log_json['process_id']).to be_a(Integer)
      end
    end

    context 'when the network request times out' do
      before do
        # Simulate timeout by raising Timeout::Error
        allow(TCPSocket).to receive(:new).and_raise(Timeout::Error)
      end

      it 'returns a request timeout error' do
        post :create, params: { destination_address: 'invalid_address', destination_port: destination_port }

        expect(response).to have_http_status(:request_timeout)
        expect(JSON.parse(response.body)['error']).to eq('Connection timed out')
      end
    end

    context 'when the network request fails due to a bad address' do
      it 'returns a bad request error' do
        post :create, params: { destination_address: 'invalid_address', destination_port: destination_port }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to include('Failed to establish connection')
      end
    end

    context 'when destination_address is missing' do
      it 'returns a bad request error' do
        post :create, params: { destination_port: destination_port, data: 'Test data' }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('Destination address and port are required')
      end
    end

    context 'when destination_port is missing' do
      it 'returns a bad request error' do
        post :create, params: { destination_address: destination_address, data: 'Test data' }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('Destination address and port are required')
      end
    end

    context 'when destination_port is not a valid integer' do
      it 'returns a bad request error' do
        post :create, params: { destination_address: destination_address, destination_port: 'invalid_port', data: 'Test data' }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('Invalid destination port')
      end
    end
  end
end
