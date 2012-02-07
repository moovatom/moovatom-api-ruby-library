# :title: MoovAtom API Documentation
# The MoovEngine API provides the RESTful interface for encoding, canceling
# and querying, your videos on the MoovAtom servers. This library defines the
# methods and functionality necessary for your app to communicate with that
# interface.
#
# See README file for installation details and specific usage information.
#
# Author:: Dominic Giglio <mailto:humanshell@gmail.com>
# Copyright:: Copyright (c) 2012 Dominic Giglio - All Rights Reserved
# License:: MIT

#-- required gems/libraries
%w[net/http uri rexml/document json].each { |lib| require lib }

#-- wrap the whole library in a module to enforce namespace
module MoovAtom
  API_URL = 'https://www.moovatom.com/api/v2'
  
  class MoovEngine
    attr_reader   :response, :action
    attr_accessor :uuid, :username, :userkey, :content_type, :title, :blurb,
                  :sourcefile, :callbackurl, :format
    
    ##
    # The initializer populates the class' instance variables to hold all the
    # specifics about the video you're accessing or starting to encode.
    #
    # There are three ways to instantiate a new MoovEngine object:
    #
    # 1.) Create a new blank object and set each variable using the traditional
    # 'dot' notation:
    #
    #   me = MoovAtom::MoovEngine.new
    #   me.uuid = '123'
    #   me.username = 'jsmith'
    #   etc...
    # 
    # 2.) Supply a hash of variables as an argument:
    #
    #   me = MoovAtom::MoovEngine.new(uuid: '123', username: 'jsmith', etc...)
    # 
    # 3.) Use a block to set variables. The initialize method yields _self_ to
    # the block given:
    #
    #   me = MoovAtom::MoovEngine.new do |me|
    #     me.uuid = '123'
    #     me.username = 'jsmith'
    #     etc...
    #   end
    #
    # _self_ is yielded to the block after the hash argument has been processed
    # so you can create a new object using a combination of hash and block:
    #
    #   me = MoovAtom::MoovEngine.new(uuid: '123') do |me|
    #     me.username = 'jsmith'
    #     me.userkey = '987654321'
    #     etc...
    #   end
    #
    # All variables with the exception of @response and @action are writable.
    # @response is readable because it contains the response from MoovAtom's
    # servers (xml or json). @action gets set in each of the request methods
    # below to correctly correspond with the actions you're asking MoovAtom to
    # perform. @format allows you to get xml or json in your responses, it's
    # set to json by default. @content_type will default to 'video'.
    
    def initialize(attrs={}, &block)
      attrs.each {|k,v| instance_variable_set "@#{k}", v}
      yield self if block_given?
      @content_type = 'video' if @content_type.nil?
      @format = 'json' if @format.nil?
    end #-- initialize method
    
    ##
    # The get_details() method is responsible for communicating the details
    # about a video that has completed encoding on Moovatom's servers. It is
    # capable of accepting the same types and combinations of arguments as the
    # initialize method. You can pass a hash of attributes and/or supply a
    # block to update the internal state of the MoovEngine object prior to
    # requesting the details of an existing video. This method sets the
    # instance variable @action to 'detail' for you.
    #
    # It uses the send_request() method to assign the response from the Moovatom
    # servers to the @response instance variable. The return value will be the
    # "raw" Net::HTTP::Response object from Moovatom. This means you have access
    # to all the specific response details corresponding to the most recent
    # request available through @response.
    #
    # This allows you to check for specific attributes of the response before
    # using the content returned:
    #
    #   me = MoovAtom::MoovEngine.new do |me|
    #     me.uuid = "uuid"
    #     me.username = "username"
    #     me.userkey = "userkey"
    #   end
    #
    #   me.get_details
    #
    #   if me.response.code == 200
    #     "...do something with me.response.body..."
    #   else
    #     "EPIC FAIL"
    #   end

    def get_details(attrs={}, &block)
      @action = 'detail'
      attrs.each {|k,v| instance_variable_set "@#{k}", v}
      yield self if block_given?
      send_request
    end #-- get_details method
    
    ##
    # The get_status() method is almost identical to the get_details() method.
    # It also accepts the same type/combination of arguments and sets the
    # @action instance variable to 'status' for you. The main difference is
    # that you will receive either a success or error status response from
    # Moovatom's servers corresponding to the video of the uuid provided.

    def get_status(attrs={}, &block)
      @action = 'status'
      attrs.each {|k,v| instance_variable_set "@#{k}", v}
      yield self if block_given?
      send_request
    end #-- end get_status method
    
    ##
    # The encode() method allows you to start a new encoding on Moovatom's
    # servers. It is almost identical to the get_details() and get_status()
    # methods. You can pass the same type/combination of arguments and it also
    # sets the @action instance variable to 'encode' for you.

    def encode(attrs={}, &block)
      @action = 'encode'
      attrs.each {|k,v| instance_variable_set "@#{k}", v}
      yield self if block_given?
      send_request

      case @response
      when Hash
        @uuid = @response["uuid"]
      when REXML::Document
        @uuid = @response.root.elements["uuid"].text
      end
    end #-- encode method
    
    ##
    # The cancel() method allows you to cancel a video currently being encoded
    # by the Moovatom servers. It is almost identical to the get_details() and
    # get_status() methods. You can pass the same type/combination of arguments
    # and it also sets the @action instance variable to 'cancel' for you.

    def cancel(attrs={}, &block)
      @action = 'cancel'
      attrs.each {|k,v| instance_variable_set "@#{k}", v}
      yield self if block_given?
      send_request
    end #-- cancel method
    
    ##
    # The send_request() method is responsible for POSTing the values stored in
    # your object's instance variables to Moovatom. The response from Moovatom
    # is returned when the method finishes.

    def send_request
      data = {
        uuid: @uuid,
        username: @username,
        userkey: @userkey,
        content_type: @content_type,
        title: @title,
        blurb: @blurb,
        sourcefile: @sourcefile,
        callbackurl: @callbackurl
      }

      # create the connection object
      uri = URI.parse "#{MoovAtom::API_URL}/#{@action}.#{@format}"
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # open the connection and send request
      http.start do |http|
        req = Net::HTTP::Post.new(uri.request_uri)
        req.set_form_data(data, '&')
        @response = http.request(req)
      end

      # parse the response if request was successful
      if @response.code == "200"
        case @format
        when "json"
          @response = JSON.parse @response.body
        when "xml"
          @response = REXML::Document.new @response.body
        end
      end
    end #-- send_request method

    ##
    # Custom to_s method for pretty printing in the console

    def to_s
      puts
      35.times { print "*" }
      puts
      puts "Object ID:    #{self.object_id}"
      puts "UUID:         #{@uuid}"
      puts "Username:     #{@username}"
      puts "Userkey:      #{@userkey}"
      puts "Content Type: #{@content_type}"
      puts "Title:        #{@title}"
      puts "Blurb:        #{@blurb}"
      puts "Source File:  #{@sourcefile}"
      puts "Callback URL: #{@callbackurl}"
      puts "Action:       #{@action}"
      puts "Format:       #{@format}"
      puts "Response:     #{@response.class}"
      35.times { print "*" }
      puts
      puts
    end
    
  end #-- MoovEngine class
  
end #-- MoovAtom module

