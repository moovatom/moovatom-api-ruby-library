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
%w[net/https rexml/document builder uri].each { |item| require item }

#-- wrap the whole library in a module to enforce namespace
module MoovAtom
  API_URL_V1  = 'https://moovatom.com/api/api_request'
  API_URL_V2  = 'https://www.moovatom.com/api/v2'
  
  class MoovEngine
    attr_reader :xml_response
    attr_accessor :uuid, :username, :userkey, :content_type, :title, :blurb,
                  :sourcefile, :callbackurl
    
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
    # All variables with the exception of @xml_response and @action are
    # writable. @xml_response is only readable because it contains the
    # response from MoovAtom's servers. @action gets set in each of the
    # request methods below to correctly correspond with the actions you're
    # asking MoovAtom to perform. @content_type will default to 'video' if you
    # don't supply a value, 'video' is Moovatom's default content type.
    
    def initialize(attrs={}, &block)
      attrs.each {|k,v| instance_variable_set "@#{k}", v}
      yield self if block_given?
      @content_type = 'video' if @content_type.nil?
    end #-- initialize method
    
    ##
    #
    #

    def details()
      @action = 'details'
    end #-- details method
    
    # Use this method to get the status of a video that is currently being
    # encoded. This method requires @username, @userkey and @uuid to be set.
    #
    # If @uuid has not been set then you can pass it in as a string argument.
    #
    # Usage:
    #
    def status()
      @action = 'status'
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
    #
    def encode
      @action = 'encode'
    end #-- encode method
    
    # Use this method to cancel the encoding of a video.
    # This method requires @username, @userkey and @uuid to be set.
    #
    # If @uuid has not been set then you can pass it in as a string argument.
    #
    # Usage:
    #
    def cancel()
      @action = 'cancel'
    end #-- cancel method
    
    private
    
    # Creates the XML object that is post'd to the MoovAtom servers
    def build_xml_request
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
    end #-- build_xml_request method
    
    # Sends the XML object to the MoovAtom servers
    def send_xml_request(xml, url = MoovAtom::API_URL_V2)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      response = http.post(uri.request_uri, "xml=#{URI.escape(xml)}")
    end #-- send_xml_request method
    
  end #-- MoovEngine class
  
end #-- MoovAtom module

