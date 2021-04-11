# import Set datatype for storing data and securerandom to generate uuid
require 'securerandom'
require 'Set'

class KeyServer
    #declare variables
    attr_reader :keys, :ttl, :timeout, :deleted_keys
    $BLOCKED = 'blocked'
    $UNBLOCKED = 'unblocked'

    #initialize variables that will be used throughout the application
    def initialize(ttl = 300, timeout = 60)
        @keys = Hash.new({})
        @deleted_keys = Set.new
        @ttl = ttl
        @timeout = timeout
    end

    # get a random key
    def get_random_key
        SecureRandom.hex(10)
    end

    #get unblocked key array
    def get_list_of_unblocked_key
        unblocked_keys = @keys.select { |
            key, value|  
            value[:status] != $BLOCKED
        }
        unblocked_keys.keys
    end

    #get blocked key array
    def get_list_of_blocked_keys
        @keys.keys - get_list_of_unblocked_key
    end

    #block a key and update status and timestamp
    def block_key(key)
        return nil if @keys[key] == {}
        @keys[key][:status] = $BLOCKED
        @keys[key][:time_stamp] = Time.now.to_i
    end

    #unblock the key and update its status
    def unblock_key(key)
        return nil if @keys[key] == {}
        if @keys[key][:status] == $BLOCKED
            @keys[key][:status] = $UNBLOCKED
            return "Successfully unblocked #{key}."
        else
            return "The key is already unblocked."
        end
    end

    #delete the key and remove from keys list and add it to the deleted keys list
    def delete_key(key)
        return nil if @keys[key] == {}
        @keys.delete(key)
        @deleted_keys.add(key)
        return "'Successfully deleted #{key}."
    end

    #generate keys based upon the count provided in the function param
    def generate_keys(count = 5)
        generated_keys = []
        count.times {
            key = get_random_key
            if @deleted_keys.include?(key)
                key = get_random_key
            end
            generated_keys.push(key)
            @keys[key] = { time_stamp: Time.now.to_i, status: $UNBLOCKED }
        }
        generated_keys
    end

    #fetch a key which is not blocked from the pool of keys on a random basis
    def get_key
        key = get_list_of_unblocked_key.sample
        if key == nil
            return nil
        else
            block_key(key)
            return key
        end
    end

    
    #keep the key alive by calling it regularly to update the timestamp or 
    #else delete the key after the conditon fits in
    def keep_key_alive_based_ts(key)
        if @keys[key] == {}
            return nil
        elsif Time.now.to_i - @keys[key][:time_stamp] < @ttl
            @keys[key][:time_stamp] = Time.now.to_i
            return true
        else
            delete_key(key)
            return false
        end
    end

    #perform action of either updating the status or deleting the key based on conditon
    def perform_action_keys_based_on_conditions
        current_ts = Time.now.to_i
        @keys.each {
            |key, value|
            if current_ts - @keys[key][:time_stamp] >= @ttl
                delete_key(key)
            elsif current_ts - @keys[key][:time_stamp] >= @timeout
                value[:status] = $UNBLOCKED
            end
        }
    end
    
end