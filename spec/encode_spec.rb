require "spec_helper"

# this file contains all the tests associated with requesting a new encoding on
# Moovatom's servers.

describe MoovAtom::MoovEngine, "Encode Request Unit Tests" do

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
    @url = "#{MoovAtom::API_URL}/encode"
    json = File.join(File.dirname(__FILE__), 'fixtures', 'encode.json')
    FakeWeb.register_uri(:post, "#{@url}.json", :body => json)
    xml = File.join(File.dirname(__FILE__), 'fixtures', 'encode.xml')
    FakeWeb.register_uri(:post, "#{@url}.xml", :body => xml)
  end

  after do
    # clean up the registry after each test
    FakeWeb.clean_registry

    # enable all real requests after testing
    FakeWeb.allow_net_connect = true
  end

  it "accepts a hash to update attributes" do

    # create a MoovEngine object using the values from the @vars1 hash
    me = MoovAtom::MoovEngine.new @vars1

    # call encode() passing the hash of values from @vars2
    me.encode @vars2

    # the instance 'me' should now contain the values from the @vars2 hash
    me.uuid.must_equal @vars1[:uuid]
    me.username.must_equal @vars2[:username]
    me.userkey.must_equal @vars2[:userkey]
    me.title.must_equal @vars2[:title]
    me.blurb.must_equal @vars2[:blurb]
    me.sourcefile.must_equal @vars2[:sourcefile]
    me.callbackurl.must_equal @vars2[:callbackurl]
  end

  it "accepts a block to update attributes" do

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

    # call encode() passing a block that sets instance variables to the
    # values in the @vars2 hash
    me.encode do |me|
      me.uuid = @vars2[:uuid]
      me.username = @vars2[:username]
      me.userkey = @vars2[:userkey]
      me.title = @vars2[:title]
      me.blurb = @vars2[:blurb]
      me.sourcefile = @vars2[:sourcefile]
      me.callbackurl = @vars2[:callbackurl]
    end

    # the instance 'me' should now contain the values from the @vars2 hash
    me.uuid.must_equal @vars1[:uuid]
    me.username.must_equal @vars2[:username]
    me.userkey.must_equal @vars2[:userkey]
    me.title.must_equal @vars2[:title]
    me.blurb.must_equal @vars2[:blurb]
    me.sourcefile.must_equal @vars2[:sourcefile]
    me.callbackurl.must_equal @vars2[:callbackurl]
  end

  it "sets the action attribute to encode" do

    # create a new MoovEngine object
    me = MoovAtom::MoovEngine.new @vars1

    # call the encode() method
    me.encode

    # after calling encode() the @action should be 'encode'
    me.action.must_equal 'encode'
  end

  # tests for the api call to get details about an existing video
  describe "API Requests" do

    it "starts a new encoding using json" do
      @me.encode
      @me.response["uuid"].must_equal @vars1[:uuid]
    end

    it "starts a new encoding using xml" do
      @me.format = 'xml'
      @me.encode
      @me.response.root.elements["uuid"].text.must_equal @vars1[:uuid]
    end

  end

end
