require 'webrick'
require 'rails_lite'

describe Params do
  before(:all) do
    class UsersController < ControllerBase
      def index
      end
    end
  end

  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:users_controller) { UsersController.new(req, res) }

  it 'handles an empty request' do
    expect { Params.new(req) }.to_not raise_error
  end

  context 'query string' do
    it 'handles single key and value' do
      req.query_string = 'key=val'
      params = Params.new(req)
      expect(params['key']).to eq('val')
    end

    it 'handles multiple keys and values' do
      req.query_string = 'key=val&key2=val2'
      params = Params.new(req)
      expect(params['key']).to eq('val')
      expect(params['key2']).to eq('val2')
    end

    it 'handles nested keys' do
      req.query_string = 'user[address][street]=main'
      params = Params.new(req)
      expect(params['user']['address']['street']).to eq('main')
    end
  end

  context 'post body' do
    it 'handles single key and value' do
      req.stub(:body) { 'key=val' }
      params = Params.new(req)
      expect(params['key']).to eq('val')
    end

    it 'handles multiple keys and values' do
      req.stub(:body) { 'key=val&key2=val2' }
      params = Params.new(req)
      expect(params['key']).to eq('val')
      expect(params['key2']).to eq('val2')
    end

    it 'handles nested keys' do
      allow(req).to receive(:body) { 'user[address][street]=main' }
      params = Params.new(req)
      expect(params['user']['address']['street']).to eq('main')
    end
  end

  context 'route params' do
    it 'handles route params' do
      params = Params.new(req, 'id' => 5, 'user_id' => 22)
      expect(params['id']).to eq(5)
      expect(params['user_id']).to eq(22)
    end
  end

  describe 'strong parameters' do
    describe '#permit' do
      it 'allows the permitting of multiple attributes' do
        req.query_string = 'key=val&key2=val2&key3=val3'
        params = Params.new(req)
        params.permit('key', 'key2')
        expect(params).to be_permitted('key')
        expect(params).to be_permitted('key2')
        expect(params).not_to be_permitted('key3')
      end

      it 'collects up permitted keys across multiple calls' do
        req.query_string = 'key=val&key2=val2&key3=val3'
        params = Params.new(req)
        params.permit('key')
        params.permit('key2')
        expect(params).to be_permitted('key')
        expect(params).to be_permitted('key2')
        expect(params).not_to be_permitted('key3')
      end
    end

    describe '#require' do
      it 'throws an error if the attribute does not exist' do
        req.query_string = 'key=val'
        params = Params.new(req)
        expect { params.require('key') }.to_not raise_error
        expect { params.require('key2') }.to raise_error(Params::AttributeNotFoundError)
      end
    end

    describe 'interaction with ARLite models' do
      it 'throws a ForbiddenAttributesError if mass assignment is attempted with unpermitted attributes'
    end
  end
end
