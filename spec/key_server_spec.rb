require_relative '../key_server'


describe KeyServer do
    before :all do
        @key_server = KeyServer.new
    end

    describe '#initialize' do
        it 'should return a new KeyServer object' do
            expect(@key_server).to be_a KeyServer
        end

        it 'should not return nil' do
            expect(@key_server).not_to be_nil
        end
    end

    describe '#get_random_key' do
        it 'should return a key with length 20' do
            key = @key_server.get_random_key
            expect(key.length).to eq(20)
        end
    end

    describe '#generate_keys' do
        it 'should return a keys array of given length or fallback to 5' do
            keys = @key_server.generate_keys()
            expect(keys.size).to eq(5)
        end

        it 'should initialize timestamp of all keys to current time' do
            result = true
            @key_server.keys.each do |k, _v|
                result &= !@key_server.keys[k][:timestamp]
            end
            expect(result).to be_truthy
        end
    end

    describe '#get_key' do
        it 'should return a key if available' do
            @key_server.generate_keys(3)
            key = @key_server.get_key
            expect(key).not_to be_nil
        end

        it 'should return 404 if no key available' do
            @key_server.get_key until @key_server.get_list_of_unblocked_key.empty?
            key = @key_server.get_key
            expect(key).to be_nil
        end
    end

    describe '#unblock_key' do
        it 'returns false if no key found' do
            expect(@key_server.unblock_key('samplekey')).to be_falsey
        end

        it 'unblocks a key if given key argument is valid' do
            @key_server.generate_keys(1)
            key = @key_server.get_key
            @key_server.unblock_key(key)
            expect(@key_server.keys).to have_key(key)
        end
    end

    describe '#delete_key' do
        it 'returns false if no key found' do
            expect(@key_server.delete_key('samplekey')).to be_falsey
        end

        it 'deletes a key if given key argument is valid' do
            @key_server.generate_keys(1)
            key = @key_server.get_key
            @key_server.delete_key(key)
            expect(@key_server.keys).not_to have_key(key)
            expect(@key_server.deleted_keys).to include(key)
        end
    end

    describe '#keep_key_alive_based_ts' do
        it 'returns false if no key found' do
            expect(@key_server.keep_key_alive_based_ts('samplekey')).to be_falsey
        end

        it 'update the timestamp if ttl is less than the diff between previous timestamp and current timestamp' do
            @key_server.generate_keys(1)
            key = @key_server.get_key
            updated_timestamp = @key_server.keys[key][:time_stamp].to_i
            @key_server.keep_key_alive_based_ts(key)
            expect(updated_timestamp).to eq(Time.now.to_i)
        end

        it 'delete the key if ttl is more than the diff between previous timestamp and current timestamp' do
            @key_server.generate_keys(1)
            key = @key_server.get_key
            expect(@key_server.keys[key][:status]).to eq('blocked')
            @key_server.keys[key][:time_stamp] = Time.now.to_i - 301
            @key_server.keep_key_alive_based_ts(key)
            expect(@key_server.deleted_keys).to include(key)
        end
    end

    describe '#perform_action_keys_based_on_conditions' do
        before :all do
            @current_ts = Time.now.to_i
        end

        it 'update the status if timeout is less than the diff between previous timestamp and current timestamp' do
            @key_server.generate_keys(1)
            key = @key_server.get_key
            expect(@key_server.keys[key][:status]).to eq('blocked')
            @key_server.keys[key][:time_stamp] = @current_ts - 61
            @key_server.perform_action_keys_based_on_conditions
            expect(@key_server.keys[key][:status]).to eq('unblocked')
        end

        it 'delete the key if ttl is more than the diff between previous timestamp and current timestamp' do
            @key_server.generate_keys(1)
            key = @key_server.get_key
            expect(@key_server.keys[key][:status]).to eq('blocked')
            @key_server.keys[key][:time_stamp] = @current_ts - 301
            @key_server.perform_action_keys_based_on_conditions
            expect(@key_server.deleted_keys).to include(key)
        end
    end

    
end