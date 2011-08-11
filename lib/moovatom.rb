require "./moovatom/version"

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
    
    def details
      
    end #- end details method
    
    def status
      
    end #- end status method
    
    def encode
      
    end #- end encode method
    
    def cancel
      
    end #- end cancel method
    
    
  end #-- end MoovEngine class
  
end #-- end MoovAtom module
