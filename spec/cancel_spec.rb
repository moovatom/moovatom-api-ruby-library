require "spec_helper"

# this file contains all the tests associated with cancelling the encoding of
# a video on Moovatom's servers.

describe MoovAtom::MoovEngine, "Cancel Request Unit Tests" do

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
    @url = "#{MoovAtom::API_URL}/cancel"
    json = File.join(File.dirname(__FILE__), 'fixtures', 'cancel.json')
    FakeWeb.register_uri(:post, "#{@url}.json", :body => json)
    xml = File.join(File.dirname(__FILE__), 'fixtures', 'cancel.xml')
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

    # call cancel() passing the hash of values from @vars2
    me.cancel @vars2

    # the instance 'me' should now contain the values from the @vars2 hash
    @vars2.each {|k,v| me.instance_variable_get("@#{k}").must_equal v}

  end

  it "accepts a block to update attributes" do

    # create a new MoovEngine object with a block using the values from @vars1
    me = MoovAtom::MoovEngine.new do |me|
      @vars1.each {|k,v| me.instance_variable_set "@#{k}", v}
    end

    # call cancel() passing a block that sets instance variables to the
    # values in the @vars2 hash
    me.cancel do |me|
      @vars2.each {|k,v| me.instance_variable_set "@#{k}", v}
    end

    # the instance 'me' should now contain the values from the @vars2 hash
    @vars2.each {|k,v| me.instance_variable_get("@#{k}").must_equal v}

  end

  it "sets the action attribute to cancel" do

    # create a new MoovEngine object
    me = MoovAtom::MoovEngine.new @vars1

    # call the cancel() method
    me.cancel

    # after calling cancel() @action should be 'cancel'
    me.action.must_equal 'cancel'

  end

  # tests for the api call to get details about an existing video
  describe "API Requests" do

    it "cancels encoding of a video using json" do
      @me.cancel
      @me.response["uuid"].must_equal @vars1[:uuid]
    end

    it "cancels encoding of a video using xml" do
      @me.format = 'xml'
      @me.cancel
      @me.response.root.elements["uuid"].text.must_equal @vars1[:uuid]
    end

  end

end
