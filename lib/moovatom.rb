# == MoovAtom API gem
# The MoovAtom API provides the RESTful methods for encoding videos, canceling and encoding,
# and getting the status and details of processing and completed encodings. 
#
# See README file for installation details and general usage information.
#
# Author:: Dominic Giglio <mailto:humanshell@gmail.com>

#- required gems/libraries
%w[net/http builder uri].each { |item| require item }

#- wrap the whole library in a module to enforce namespace
module MoovAtom
  
  #-- MoovAtom module constants
  API_URL  = 'moovatom.com'
  API_PATH = '/api/api_request'
  
  class MoovEngine
    
    #- class setters and getters
    attr_reader :xml_response
    attr_accessor :guid, :username, :userkey, :content_type, :title, :blurb, :sourcefile, :callbackurl
    
    # The initializer creates a set of instance variables to hold all the specifics about
    # the video you're accessing.
    #
    #- MoovEngine class initializer
    def initialize(args={})
      @guid         = args[:guid]
      @username     = args[:username]
      @userkey      = args[:userkey]
      @content_type = args[:content_type] || "video"
      @title        = args[:title]
      @blurb        = args[:blurb]
      @sourcefile   = args[:sourcefile]
      @callbackurl  = args[:callbackurl]
    end
    
    # Use this method to get the details about a video that's finished encoding
    #
    # Usage:
    # * moov_engine = MoovAtom::MoovEngine.new
    # * moov_engine.details 'GUID_OF_VIDEO'
    def details(guid)
      @guid = guid
      @action = 'details'
      @xml_response = send_xml_request(build_xml_request)
    end #- end details method
    
    # Use this method to get the status of a video that hasn't finished encoding
    #
    # Usage:
    # * moov_engine = MoovAtom::MoovEngine.new
    # * moov_engine.status 'GUID_OF_VIDEO'
    def status(guid)
      @guid = guid
      @action = 'status'
      @xml_response = send_xml_request(build_xml_request)
    end #- end status method
    
    def encode
      @action = 'encode'
      @xml_response = send_xml_request(build_xml_request)
    end #- end encode method
    
    # Use this method to cancel the encoding of a video
    #
    # Usage:
    # * moov_engine = MoovAtom::MoovEngine.new
    # * moov_engine.cancel 'GUID_OF_VIDEO'
    def cancel(guid)
      @guid = guid
      @action = 'cancel'
      @xml_response = send_xml_request(build_xml_request)
    end #- end cancel method
    
    #- start of private methods
    private
    
    #- build an xml request
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
    end #- end build_xml_request method
    
    #- send an xml request
    # Sends the XML object to the MoovAtom servers
    def send_xml_request(xml)
      Net::HTTP.start(MoovAtom::API_URL) do |http|
        http.post(MoovAtom::API_PATH, "xml=#{URI.escape(xml)}")
      end
    end #- end send_xml_request method
    
  end #- end MoovEngine class
  
end #- end MoovAtom module
