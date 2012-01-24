# :title: MoovAtom API Documentation
# The MoovEngine API provides the RESTful interface for encoding, canceling
# and querying, your videos on the MoovAtom servers. This library defines the
# methods and functionality necessary for your app to communicate with that
# interface.
#
# See README file for installation details and general usage information.
#
# Author:: Dominic Giglio <mailto:humanshell@gmail.com>
# Copyright:: Copyright (c) 2012 Dominic Giglio - All Rights Reserved
# License:: MIT

#-- required gems/libraries
%w[net/https rexml/document builder uri json].each { |item| require item }

#-- wrap the whole library in a module to enforce namespace
module MoovAtom
  API_URL  = 'https://www.moovatom.com/api/v2'
  
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
    # Create a new blank object and set each variable using the traditional
    # dot notation:
    #
    #   me = MoovAtom::MoovEngine.new
    #   me.uuid = '123'
    #   me.username = 'jsmith'
    #   etc...
    # 
    # Supply a hash of variables as an argument:
    #
    #   me = MoovAtom::MoovEngine.new(uuid: '123', username: 'jsmith', etc...)
    # 
    # Use a block to set variables. The initialize method yields _self_ to
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
    # perform. @format allows you to use xml or json in your requests, it's
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
    # It uses a combination of the build_request and send_request methods to
    # assign the response from the Moovatom servers to the @response instance
    # variable. The return value of the build_request method is passed to the
    # send_request method, the return value will be the "raw"
    # Net::HTTP::Response object from Moovatom. This means you have access to
    # all the specific response details corresponding to the most recent
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
      @response = send_request(build_request)
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
      @response = send_request(build_request)
    end #-- end get_status method
    
    ##
    #
    #

    def encode
      @action = 'encode'
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
      @response = send_request(build_request)
    end #-- cancel method
    
    ##
    # This method uses the values stored in each instance variable to create
    # either the json or xml request that gets POST'd to the Moovatom servers
    # through the send_request() method below.
    
    def build_request
      if @format == "json"
        {
          uuid: @uuid,
          username: @username,
          userkey: @userkey,
          content_type: @content_type,
          title: @title,
          blurb: @blurb,
          sourcefile: @sourcefile,
          callbackurl: @callbackurl
        }.to_json
      else
        b = Builder::XmlMarkup.new
        b.instruct!
        xml = b.request do |r|
          r.uuid(@uuid)
          r.username(@username)
          r.userkey(@userkey)
          r.action(@action)
          r.content_type(@content_type)
          r.title(@title)
          r.blurb(@blurb)
          r.sourcefile(@sourcefile)
          r.callbackurl(@callbackurl)
        end
      end
    end #-- build_request method
    
    ##
    # This method takes the request object (either json or xml) that's
    # genreated by the build_request() method and POST's it to the Moovatom
    # servers. The response from Moovatom is returned when the method finishes.

    def send_request(req)
      uri = URI.parse("#{MoovAtom::API_URL}/#{@action}.#{@format}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      if @format == "json"
        http.post(uri.request_uri, "json=#{URI.escape(req)}")
      else
        http.post(uri.request_uri, "xml=#{URI.escape(req)}")
      end
    end #-- send_request method
    
  end #-- MoovEngine class
  
end #-- MoovAtom module

