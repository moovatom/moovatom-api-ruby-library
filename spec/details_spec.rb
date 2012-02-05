require "spec_helper"

# this file contains all the tests associated with requesting the details of a
# video on Moovatom's servers.

describe MoovAtom::MoovEngine, "Details Request Unit Tests" do

  before do
    @vars1 = {
      uuid: '123',
      username: 'jsmith',
      userkey: '987654321',
      title: 'My Greatest Movie',
      blurb: 'The greatest movie ever made',
      sourcefile: 'http://example.com/greatest.mp4',
      callbackurl: 'http://example.com/callback'
    }

    @vars2 = {
      uuid: '321',
      username: 'asmith',
      userkey: '123456789',
      title: 'My Best Movie',
      blurb: 'The bestest movie ever made',
      sourcefile: 'http://example.com/best.mp4',
      callbackurl: 'http://example.com/callback_url'
    }

    # mock up the connection to moovatom.com
    @me = MoovAtom::MoovEngine.new @vars1
    @url = "#{MoovAtom::API_URL}/detail"
    json = File.join(File.dirname(__FILE__), 'fixtures', 'detail.json')
    FakeWeb.register_uri(:post, "#{@url}.json", :body => json)
    xml = File.join(File.dirname(__FILE__), 'fixtures', 'detail.xml')
    FakeWeb.register_uri(:post, "#{@url}.xml", :body => xml)
  end

  after do
    # clean up the registry after each test
    FakeWeb.clean_registry

    # enable all real requests after testing
    FakeWeb.allow_net_connect = true
  end

  it "accepts a hash to update internal variables" do

    # create a MoovEngine object using the values from the @vars1 hash
    me = MoovAtom::MoovEngine.new @vars1

    # call get_details() passing the hash of values from @vars2
    me.get_details @vars2

    # the instance 'me' should now contain the values from the @vars2 hash
    me.uuid.must_equal @vars2[:uuid]
    me.username.must_equal @vars2[:username]
    me.userkey.must_equal @vars2[:userkey]
    me.title.must_equal @vars2[:title]
    me.blurb.must_equal @vars2[:blurb]
    me.sourcefile.must_equal @vars2[:sourcefile]
    me.callbackurl.must_equal @vars2[:callbackurl]
  end

  it "accepts a block to update internal variables" do

    # create a new MoovEngine object with a block using the values from @vars1
    me = MoovAtom::MoovEngine.new do |me|
      me.uuid = @vars1[:uuid]
      me.username = @vars1[:username]
      me.userkey = @vars1[:userkey]
      me.title = @vars1[:title]
      me.blurb = @vars1[:blurb]
      me.sourcefile = @vars1[:sourcefile]
      me.callbackurl = @vars1[:callbackurl]
    end

    # call get_details() passing a block that sets instance variables to the
    # values in the @vars2 hash
    me.get_details do |me|
      me.uuid = @vars2[:uuid]
      me.username = @vars2[:username]
      me.userkey = @vars2[:userkey]
      me.title = @vars2[:title]
      me.blurb = @vars2[:blurb]
      me.sourcefile = @vars2[:sourcefile]
      me.callbackurl = @vars2[:callbackurl]
    end

    # the instance 'me' should now contain the values from the @vars2 hash
    me.uuid.must_equal @vars2[:uuid]
    me.username.must_equal @vars2[:username]
    me.userkey.must_equal @vars2[:userkey]
    me.title.must_equal @vars2[:title]
    me.blurb.must_equal @vars2[:blurb]
    me.sourcefile.must_equal @vars2[:sourcefile]
    me.callbackurl.must_equal @vars2[:callbackurl]
  end

  it "sets the action instance variable to details" do

    # create a new MoovEngine object
    me = MoovAtom::MoovEngine.new @vars1

    # call the get_details() method
    me.get_details

    # after calling get_details() the @action should be 'detail'
    me.action.must_equal 'detail'
  end

  # tests for the api call to get details about an existing video
  describe "API Requests" do

    it "builds well formed json" do
      json = JSON.parse @me.build_request
      json['uuid'].must_equal @vars1[:uuid]
      json['username'].must_equal @vars1[:username]
      json['userkey'].must_equal @vars1[:userkey]
      json['title'].must_equal @vars1[:title]
      json['blurb'].must_equal @vars1[:blurb]
      json['sourcefile'].must_equal @vars1[:sourcefile]
      json['callbackurl'].must_equal @vars1[:callbackurl]
    end

    it "builds well formed xml" do
      @me.format = 'xml'
      xml = @me.build_request
      xml.must_include "<uuid>#{@vars1[:uuid]}</uuid>"
      xml.must_include "<username>#{@vars1[:username]}</username>"
      xml.must_include "<userkey>#{@vars1[:userkey]}</userkey>"
      xml.must_include "<title>#{@vars1[:title]}</title>"
      xml.must_include "<blurb>#{@vars1[:blurb]}</blurb>"
      xml.must_include "<sourcefile>#{@vars1[:sourcefile]}</sourcefile>"
      xml.must_include "<callbackurl>#{@vars1[:callbackurl]}</callbackurl>"
    end

    it "gets the details of an existing video using json" do
      @me.get_details
      @me.response.code.must_equal '200'
      json_res = JSON.parse(@me.response.body)
      json_res['uuid'].must_equal @vars1[:uuid]
    end

    it "gets the details of an existing video using xml" do
      @me.format = 'xml'
      @me.get_details
      @me.response.code.must_equal '200'
      @me.response.body.must_include "<uuid>#{@vars1[:uuid]}</uuid>"
    end

  end

end
