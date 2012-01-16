# :title: MoovAtom API Documentation
# The MoovEngine API provides the RESTful interface for encoding, canceling and querying,
# your videos on the MoovAtom servers. This library defines the methods and functionality
# necessary for your app to communicate with that interface.
#
# See README file for installation details and general usage information.
#
# Author:: Dominic Giglio <mailto:humanshell@gmail.com>
# Copyright:: Copyright (c) 2011 Dominic Giglio - All Rights Reserved
# License:: MIT

#-- required gems/libraries
%w[net/https rexml/document builder uri].each { |item| require item }

#-- wrap the whole library in a module to enforce namespace
module MoovAtom
  
  #-- MoovAtom module constants
  API_URL  = 'https://moovatom.com/api/api_request'
  
  class MoovEngine
    
    #-- class setters and getters
    attr_reader :xml_response
    attr_accessor :guid, :username, :userkey, :content_type, :title, :blurb, :sourcefile, :callbackurl
    
    # The initializer creates a set of instance variables to hold all the specifics about
    # the video you're accessing. You can define these variables when instantiating a new
    # MoovEngine object or after a blank object has been created. All variables with the
    # exception of @xml_response and @action are writable. @xml_response is only readable
    # because it contains the respnse from MoovAtom's servers. @action gets set in each of
    # the methods below to correctly correspond with the associated request.
    #
    # Usage:
    # * moov_engine = MoovAtom::MoovEngine.new
    # * moov_engine.username = 'YOUR_USERNAME'
    # * moov_engine.userkey = 'YOUR_USERKEY'
    # * etc...
    #
    # Or:
    # * args = { username: 'YOUR_USERNAME', userkey: 'YOUR_USERKEY', etc... }
    # * moov_engine = MoovAtom::MoovEngine.new(args)
    def initialize(args={})
      @guid         = args[:guid]
      @username     = args[:username]
      @userkey      = args[:userkey]
      @content_type = args[:content_type] || "video"
      @title        = args[:title]
      @blurb        = args[:blurb]
      @sourcefile   = args[:sourcefile]
      @callbackurl  = args[:callbackurl]
    end #-- end initialize method
    
    # Use this method to get the details about a video that's finished encoding.
    # This method requires @username, @userkey and @guid to be set.
    #
    # If @guid has not yet been set then you can pass it in as a string argument.
    #
    # Usage:
    # * moov_engine.details
    # * moov_engine.details 'GUID_OF_VIDEO'
    def details(guid = "")
      @guid = guid if @guid.nil?
      @action = 'details'
      @xml_response = send_xml_request(build_xml_request)
    end #-- end details method
    
    # Use this method to get the status of a video that is currently being encoded.
    # This method requires @username, @userkey and @guid to be set.
    #
    # If @guid has not yet been set then you can pass it in as a string argument.
    #
    # Usage:
    # * moov_engine.status
    # * moov_engine.status 'GUID_OF_VIDEO'
    def status(guid = "")
      @guid = guid if @guid.nil?
      @action = 'status'
      @xml_response = send_xml_request(build_xml_request)
    end #-- end status method
    
    # Use this method to start encoding a new video.
    # This method requires the following variables be set:
    # * @username
    # * @userkey
    # * @content_type
    # * @title
    # * @blurb
    # * @sourcefile
    # * @callbackurl
    #
    # Usage:
    # * moov_engine.details
    def encode
      @action = 'encode'
      @xml_response = send_xml_request(build_xml_request)
      
      if @xml_response.code == "200"
        xml_doc = REXML::Document.new @xml_response.body
        @guid = xml_doc.root.elements["uuid"].text
      end
    end #-- end encode method
    
    # Use this method to cancel the encoding of a video.
    # This method requires @username, @userkey and @guid to be set.
    #
    # If @guid has not yet been set then you can pass it in as a string argument.
    #
    # Usage:
    # * moov_engine.cancel
    # * moov_engine.cancel 'GUID_OF_VIDEO'
    def cancel(guid = "")
      @guid = guid if @guid.nil?
      @action = 'cancel'
      @xml_response = send_xml_request(build_xml_request)
    end #-- end cancel method
    
    #-- start of private methods
    private
    
    # Creates the XML object that is post'd to the MoovAtom servers
    def build_xml_request
      b = Builder::XmlMarkup.new
      b.instruct!
      xml = b.request do |r|
        r.uuid(@guid)
        r.username(@username)
        r.userkey(@userkey)
        r.action(@action)
        r.content_type(@content_type)
        r.title(@title)
        r.blurb(@blurb)
        r.sourcefile(@sourcefile)
        r.callbackurl(@callbackurl)
      end
    end #-- end build_xml_request method
    
    # Sends the XML object to the MoovAtom servers
    def send_xml_request(xml)
      uri = URI.parse(MoovAtom::API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      response = http.post(uri.request_uri, "xml=#{URI.escape(xml)}")
    end #-- end send_xml_request method
    
  end #-- end MoovEngine class
  
end #-- end MoovAtom module
