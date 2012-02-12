require "spec_helper"

# this file contains all the tests associated with requesting the status of a
# video on Moovatom's servers.

describe MoovAtom::MoovEngine, "Status Request Unit Tests" do

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
    @url = "#{MoovAtom::API_URL}/status"
    json_error = File.join(File.dirname(__FILE__), 'fixtures', 'status_error.json')
    FakeWeb.register_uri(:post, "#{@url}.json", :body => json_error)
    json_success = File.join(File.dirname(__FILE__), 'fixtures', 'status_success.json')
    FakeWeb.register_uri(:post, "#{@url}.json", :body => json_success)
    xml_error = File.join(File.dirname(__FILE__), 'fixtures', 'status_error.xml')
    FakeWeb.register_uri(:post, "#{@url}.xml", :body => xml_error)
    xml_success = File.join(File.dirname(__FILE__), 'fixtures', 'status_success.xml')
    FakeWeb.register_uri(:post, "#{@url}.xml", :body => xml_success)
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

    # call get_status() passing the hash of values from @vars2
    me.get_status @vars2

    # the instance 'me' should now contain the values from the @vars2 hash
    @vars2.each {|k,v| me.instance_variable_get("@#{k}").must_equal v}
  end

  it "accepts a block to update attributes" do

    # create a new MoovEngine object with a block using the values from @vars1
    me = MoovAtom::MoovEngine.new do |me|
      @vars1.each {|k,v| me.instance_variable_set "@#{k}", v}
    end

    # call get_status() passing a block that sets instance variables to the
    # values in the @vars2 hash
    me.get_status do |me|
      @vars2.each {|k,v| me.instance_variable_set "@#{k}", v}
    end

    # the instance 'me' should now contain the values from the @vars2 hash
    @vars2.each {|k,v| me.instance_variable_get("@#{k}").must_equal v}
  end

  it "sets the action attribute to status" do

    # create a new MoovEngine object
    me = MoovAtom::MoovEngine.new @vars1

    # call the get_details() method
    me.get_status

    # after calling get_status() @action should be 'status'
    me.action.must_equal 'status'
  end

  # tests for the api call to get details about an existing video
  describe "API Requests" do

    it "gets status of a video using json" do
      @me.get_status
      @me.response["uuid"].must_equal @vars1[:uuid]
    end

    it "gets status of a video using xml" do
      @me.format = 'xml'
      @me.get_status
      @me.response.root.elements["uuid"].text.must_equal @vars1[:uuid]
    end

  end

end
