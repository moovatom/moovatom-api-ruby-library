require "spec_helper"

# this file contains all the tests associated with searching for
# videos on Moovatom's servers.

describe MoovAtom::MoovEngine, "Media Search Request Unit Tests" do

  before do
    @vars1 = {
      uuid: '123',
      username: 'jsmith',
      userkey: '987654321',
      search_term: 'Example Query',
      title: 'My Greatest Movie',
      blurb: 'The greatest movie ever made',
      sourcefile: 'http://example.com/greatest.mp4',
      callbackurl: 'http://example.com/callback'
    }

    @vars2 = {
      uuid: '321',
      username: 'asmith',
      userkey: '123456789',
      search_term: 'Example Query',
      title: 'My Best Movie',
      blurb: 'The bestest movie ever made',
      sourcefile: 'http://example.com/best.mp4',
      callbackurl: 'http://example.com/callback_url'
    }

    # mock up the connection to moovatom.com
    @me = MoovAtom::MoovEngine.new @vars1
    @url = "#{MoovAtom::API_URL}/media_search"
    json = File.join(File.dirname(__FILE__), 'fixtures', 'media_search.json')
    FakeWeb.register_uri(:post, "#{@url}.json", :body => json)
    xml = File.join(File.dirname(__FILE__), 'fixtures', 'media_search.xml')
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

    # call get_details() passing the hash of values from @vars2
    me.media_search @vars2

    # the instance 'me' should now contain the values from the @vars2 hash
    @vars2.each {|k,v| me.instance_variable_get("@#{k}").must_equal v}
  end

  it "accepts a block to update attributes" do

    # create a new MoovEngine object with a block using the values from @vars1
    me = MoovAtom::MoovEngine.new do |me|
      @vars1.each {|k,v| me.instance_variable_set "@#{k}", v}
    end

    # call get_details() passing a block that sets instance variables to the
    # values in the @vars2 hash
    me.media_search do |me|
      @vars2.each {|k,v| me.instance_variable_set "@#{k}", v}
    end

    # the instance 'me' should now contain the values from the @vars2 hash
    @vars2.each {|k,v| me.instance_variable_get("@#{k}").must_equal v}
  end

  it "sets the action attribute to media_search" do

    # create a new MoovEngine object
    me = MoovAtom::MoovEngine.new @vars1

    # call the get_details() method
    me.media_search

    # after calling get_details() @action should be 'detail'
    me.action.must_equal 'media_search'
  end

  # tests for the api call to get details about an existing video
  describe "API Requests" do

    it "searches for a video using json" do
      @me.media_search
      @me.response["user"].must_equal "USERNAME"
    end

    it "searches for a video using xml" do
      @me.format = 'xml'
      @me.media_search
      @me.response.root.elements["user"].text.must_equal "USERNAME"
    end

  end

end
