#- required gems/libraries
%w[./moovatom/version net/http builder uri].each { |item| require item }

module MoovAtom
  
  #-- module constants
  REQ_URL  = 'moovatom.com'
  REQ_PATH = '/api/api_request'
  
  class MoovEngine
    
    #-- class setters and setters
    attr_reader :xml_response
    attr_accessor :guid, :username, :userkey, :action, :content_type, :title, :blurb, :sourcefile, :callbackurl
    
    #- moovengine class initializer
    def initialize(args={})
      @guid         = args[:guid]
      @username     = args[:username]
      @userkey      = args[:userkey]
      @action       = args[:action] || 'details'
      @content_type = args[:content_type] || "video"
      @title        = args[:title]
      @blurb        = args[:blurb]
      @sourcefile   = args[:sourcefile]
      @callbackurl  = args[:callbackurl]
    end
    
    def details(guid)
      @guid = guid
      @action = 'details'
    end #- end details method
    
    def status(guid)
      @guid = guid
      @action = 'status'
    end #- end status method
    
    def encode
      
    end #- end encode method
    
    def cancel(guid)
      @guid = guid
      @action = 'cancel'
    end #- end cancel method
    
    #- start of private methods
    private
    
    #- build an xml request
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
    
    #- send an xml request
    def send_xml_request(xml)

      Net::HTTP.start(@@req_url) do |http|
        http.post(@@req_path, "xml=#{URI.escape(xml)}")
      end

    end #-- end send_xml_request method
    
    
  end #-- end MoovEngine class
  
end #-- end MoovAtom module
