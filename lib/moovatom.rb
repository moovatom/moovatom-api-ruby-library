require "moovatom/version"

module MoovAtom
  
  #-- module constants
  REQ_URL  = 'moovatom.com'
  REQ_PATH = '/api/api_request'
  
  class MoovEngine
    
    #-- class setters and setters
    attr_reader :xml_response
    attr_accessor :guid, :username, :userkey, :action, :content_type, :title, :blurb, :sourcefile, :callbackurl
    
    def initialize(args={})
      
    end
    
    
    
    
  end #-- end MoovEngine class
  
end #-- end MoovAtom module
