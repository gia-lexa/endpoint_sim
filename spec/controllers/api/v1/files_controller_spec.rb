# spec/controllers/api/v1/files_controller_spec.rb

require 'rails_helper'

RSpec.describe Api::V1::FilesController, type: :controller do
  let(:test_file_path) { Rails.root.join('tmp', 'testfile.txt').to_s }
  let(:log_file_path) { Rails.root.join('log', 'activity_log.json') }

  after(:each) do
    # Clean up test file and log file after each test
    File.delete(test_file_path) if File.exist?(test_file_path)
    File.truncate(log_file_path, 0) if File.exist?(log_file_path)  # Clear log file content
  end

  describe 'POST #create' do
    context 'when valid file path is provided' do
      it 'creates the file and logs the activity' do
        post :create, params: { file_path: test_file_path, content: 'Hello, World!' }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('File created')
        expect(File.exist?(test_file_path)).to be(true)
        
        # Check if log file contains the correct entry
        log_content = File.read(log_file_path)
        expect(log_content).to include('create')
        expect(log_content).to include(test_file_path)
      end
    end

    context 'when file path is missing' do
      it 'returns a bad request error' do
        post :create, params: { content: 'No path!' }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('File path is missing')
      end
    end
  end

  describe 'POST #update' do
    context 'when the file exists' do
      before do
        File.open(test_file_path, 'w') { |file| file.write('Initial content') }
      end

      it 'updates the file content and logs the activity' do
        patch :update, params: { file_path: test_file_path, new_content: 'Updated content' }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('File updated')
        expect(File.read(test_file_path)).to eq('Updated content')
        
        # Check if log file contains the correct entry
        log_content = File.read(log_file_path)
        expect(log_content).to include('update')
        expect(log_content).to include(test_file_path)
      end
    end

    context 'when the file does not exist' do
      it 'returns a not found error' do
        patch :update, params: { file_path: test_file_path, new_content: 'Will not be written' }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('File not found')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the file exists' do
      before do
        File.open(test_file_path, 'w') { |file| file.write('Some content') }
      end

      it 'deletes the file and logs the activity' do
        delete :destroy, params: { file_path: test_file_path }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('File deleted')
        expect(File.exist?(test_file_path)).to be(false)
        
        # Check if log file contains the correct entry
        log_content = File.read(log_file_path)
        expect(log_content).to include('delete')
        expect(log_content).to include(test_file_path)
      end
    end

    context 'when the file does not exist' do
      it 'returns a not found error' do
        delete :destroy, params: { file_path: test_file_path }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('File not found')
      end
    end
  end
end
