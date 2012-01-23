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
    attr_reader :response, :action
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
    #
    #

    def get_details(attrs={}, &block)
      @action = 'detail'
      attrs.each {|k,v| instance_variable_set "@#{k}", v}
      yield self if block_given?
      @response = send_request(build_request)
    end #-- get_details method
    
    ##
    #
    #

    def status()
      @action = 'status'
    end #-- end status method
    
    ##
    #
    #

    def encode
      @action = 'encode'
    end #-- encode method
    
    ##
    #
    #

    def cancel()
      @action = 'cancel'
    end #-- cancel method
    
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
    
    # This method takes the response from the build_request() method and POST's
    # it to the Moovatom servers. The response from Moovatom is returned when
    # the method finishes.
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

