require 'rails_helper'

RSpec.describe Api::V1::LogsController, type: :controller do
  let(:log_file_path) { Rails.root.join('log', 'activity_log.json') }

  before(:each) do
    # Ensure the log directory exists
    FileUtils.mkdir_p(Rails.root.join('log'))

    # Create a sample log file
    File.open(log_file_path, 'w') do |file|
      file.puts({ timestamp: '2024-09-21T12:00:00Z', type: 'process_start', message: 'Process started' }.to_json)
      file.puts({ timestamp: '2024-09-21T12:01:00Z', type: 'file_create', message: 'File created' }.to_json)
    end
  end

  after(:each) do
    # Clean up the log file after each test
    File.delete(log_file_path) if File.exist?(log_file_path)
  end

  describe 'GET #index' do
    context 'when the log file exists' do
      it 'returns all logs when no filter is applied' do
        get :index

        expect(response).to have_http_status(:ok)
        logs = JSON.parse(response.body)
        expect(logs.count).to eq(2)  # Expecting all logs
      end

      it 'returns logs filtered by the specified type' do
        get :index, params: { type: 'process_start' }

        expect(response).to have_http_status(:ok)
        filtered_logs = JSON.parse(response.body)
        expect(filtered_logs.count).to eq(1)
        expect(filtered_logs[0]['type']).to eq('process_start')
      end
    end

    context 'when the log file does not exist' do
      before do
        File.delete(log_file_path) if File.exist?(log_file_path)
      end

      it 'returns a not found error' do
        get :index

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Log file not found')
      end
    end
  end
end
