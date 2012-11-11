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
%w[net/http uri rexml/document ostruct json].each { |lib| require lib }

#-- wrap the whole library in a module to enforce namespace
module MoovAtom
  API_URL = 'https://www.moovatom.com/api/v2'
  
  class MoovEngine
    attr_reader   :response, :action
    attr_accessor :uuid, :username, :userkey, :content_type, :search_term, :title,
                  :blurb, :sourcefile, :callbackurl, :format, :player
    
    ##
    # The initializer populates the class' instance variables to hold all the
    # specifics about the video you're accessing or starting to encode, as well
    # as the player control attributes.
    #
    # There are three ways to instantiate a new MoovEngine object:
    #
    # 1. Create a blank object and set each variable using 'dot' notation
    # 2. Supply video and/or player attributes in hashes
    # 3. Use a block to set attributes
    #
    # See the README for specific examples
    #
    # @player is a struct (OpenStruct) that holds all the attributes for your
    # video player. All variables with the exception of @response and @action
    # are writable. @response is readable because it contains the response from
    # MoovAtom's servers. @action gets set in each of the request methods below
    # to correctly correspond with the actions you're asking MoovAtom to
    # perform. @format allows you to get xml or json in your responses, it's set
    # to json by default. @content_type will default to 'video'.
    
    def initialize(vattrs={}, pattrs={}, &block)
      @player = OpenStruct.new pattrs
      vattrs.each {|k,v| instance_variable_set "@#{k}", v}
      yield self if block_given?
      @content_type = 'video' if @content_type.nil?
      @format = 'json' if @format.nil?
    end #-- initialize method
    
    ##
    # The get_details() method is responsible for communicating the details
    # about a video that has completed encoding on Moovatom's servers. You can
    # pass a hash of attributes and/or supply a block to update the internal
    # state of the MoovEngine object prior to requesting the details of an
    # existing video. This method sets the instance variable @action to 'detail'
    # for you. It uses the send_request() method to assign the response from the
    # Moovatom servers to the @response instance variable.
    #
    # See README for specific examples

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
    #
    # See README for specific examples

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
    # sets the @action instance variable to 'encode' for you. After a
    # successful response this method will set the @uuid instance variable to
    # the value returned from Moovatom.
    #
    # See README for specific examples

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
    #
    # See README for specific examples

    def cancel(attrs={}, &block)
      @action = 'cancel'
      attrs.each {|k,v| instance_variable_set "@#{k}", v}
      yield self if block_given?
      send_request
    end #-- cancel method

    ##
    # The edit_player() method allows you to change the player attributes for
    # your videos on moovatom's servers. It accepts a hash of player attributes
    # and/or a block to merge/update the @player instance variable created
    # during initialization. It POSTs this (and all other instance variables) to
    # moovatom through the send_request() method.
    #
    # See README for specific examples

    def edit_player(attrs={}, &block)
      @action = 'edit_player'
      @player.instance_variable_get("@table").merge! attrs
      yield self if block_given?
      send_request
    end #-- edit_player method

    ##
    # The delete() method allows you to delete a video that's finished encoding
    # on the Moovatom servers. It is almost identical to the get_details() and
    # get_status() methods. You can pass the same type/combination of arguments
    # and it also sets the @action instance variable to 'delete' for you.
    #
    # See README for specific examples

    def delete(attrs={}, &block)
      @action = 'delete'
      attrs.each {|k,v| instance_variable_set "@#{k}", v}
      yield self if block_given?
      send_request
    end #-- delete method

    ##
    # The media_search() method allows you to search for a video on the
    # Moovatom servers. It is almost identical to the get_details() and
    # get_status() methods. You can pass the same type/combination of arguments
    # and it also sets the @action instance variable to 'media_search' for you.
    #
    # See README for specific examples

    def media_search(attrs={}, &block)
      @action = 'media_search'
      attrs.each {|k,v| instance_variable_set "@#{k}", v}
      yield self if block_given?
      send_request
    end #-- media_search method

    private

    ##
    # The send_request() method is responsible for POSTing the values stored in
    # your object's instance variables to Moovatom. The response from Moovatom
    # is returned when the method finishes. If the response was a success it
    # will be parsed according to the value of @format.

    def send_request

      # create the connection object
      uri = URI.parse "#{MoovAtom::API_URL}/#{@action}.#{@format}"
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # open the connection and send request
      http.start do |http|
        req = Net::HTTP::Post.new(uri.request_uri)
        req.set_form_data(all_attributes, '&')
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
    # This method assembles all video and player attributes so they can be
    # easily added to the request that's POST'd to the Moovatom servers

    def all_attributes

      # get all the video instance variables
      vattrs = Hash[
        instance_variables.map do |iv|
          [iv.to_s.gsub!(/@/, ""), instance_variable_get(iv)] unless iv == :@player
        end
      ]

      # get all the player instance variables
      pattrs = Hash[
        @player.instance_variable_get("@table").keys.map do |iv|
          [iv.to_s, @player.instance_variable_get("@table")[iv].to_s]
        end
      ]

      # merge them and return as a single hash of attributes
      vattrs.merge! pattrs

    end

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
      puts "Search Term:  #{@search_term}"
      puts "Action:       #{@action}"
      puts "Format:       #{@format}"
      puts "Response:     #{@response.class}"
      puts "Player:       #{@player.instance_variable_get("@table").length} attribute(s)"
      35.times { print "*" }
      puts
      puts
    end
    
  end #-- MoovEngine class
  
end #-- MoovAtom module

