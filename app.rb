# import webframework
require 'sinatra'

# import KeyServer class for operations
require_relative './key_server.rb'

# create an intance of keyserver class inorder to access methods
key_server = KeyServer.new(300, 60)

# cron job which runs every 60 seconds to perform actions on keys.
Thread.new do
    loop do
      sleep 1
      key_server.perform_action_keys_based_on_conditions
    end
end

# check if server is running by hitting home route
get '/' do
    "Hey i am running"
end

=begin 
    used to generate keys if no param for the no. of keys to generate is provided 
    it assumes it to be 5
=end
get '/generateKeys/:noOfKeys?' do
    keys = key_server.generate_keys(params[:noOfKeys] ? params[:noOfKeys].to_i : 5)
    keys.join(', ')
end

#fetch key from the bucket of keys generated
get '/fetchKey' do
    key = key_server.get_key
    if key.nil?
        status 404
        body 'Key is not available, generate some by calling "/generateKeys"'
    else
        body key
    end
end

#unblock keys 
get '/unblock/:key' do
    response = key_server.unblock_key(params['key'])
    if response.nil?
      status 404
      body 'Key is not valid'
    else
      body response
    end
end

#delete key
get '/delete/:key' do
    response = key_server.delete_key(params['key'])
    if response.nil?
        status 404
        body 'Key is not valid'
    else
        body response
    end
end

#call to keep key alive by updating the timestamp so that its not cleared
get '/keepAlive/:key' do
    response = key_server.keep_key_alive_based_ts(params['key'])
    if response.nil?
        status 404
        body 'Key is not valid'
    else
        body 'Kept Alive'
    end
end
