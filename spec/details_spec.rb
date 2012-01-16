require "spec_helper"

describe MoovAtom::MoovEngine do
  before do
    @args = {
      username: 'jsmith',
      userkey: '123',
      guid: '456',
      title: 'Test Video Title',
      blurb: 'A Short description about the video.',
      sourcefile: 'http://example.com/path/to/file/test.mp4',
      callbackurl: 'http://example.com/job_complete'
    }

    @moov_engine = MoovAtom::MoovEngine.new @args
  end

  after do
    FakeWeb.clean_registry
  end

  describe "Details request..." do
    it "gets the details of an existing video" do
      xml = File.join(File.dirname(__FILE__), 'fixtures', 'detail.xml')
      FakeWeb.register_uri(:post, MoovAtom::API_URL, :body => xml)
      xml_res = @moov_engine.details
      xml_res.body.must_include "<uuid>456</uuid>"
      xml_res.body.must_include "<versions>"
    end
  end

  describe "Status request success..." do
    it "handles a successful status request" do
      xml = File.join(File.dirname(__FILE__), 'fixtures', 'status_success.xml')
      FakeWeb.register_uri(:post, MoovAtom::API_URL, :body => xml)
      xml_res = @moov_engine.status
      xml_res.body.must_include "<uuid>456</uuid>"
      xml_res.body.must_include "<processing>True</processing>"
      xml_res.body.must_include "<error></error>"
    end
  end

  describe "Status request error..." do
    it "handles an unsuccessful status request" do
      xml = File.join(File.dirname(__FILE__), 'fixtures', 'status_error.xml')
      FakeWeb.register_uri(:post, MoovAtom::API_URL, :body => xml)
      xml_res = @moov_engine.status
      xml_res.body.must_include "<uuid>456</uuid>"
      xml_res.body.must_include "<processing>False</processing>"
      xml_res.body.must_include "<error>This was not a recognized format.</error>"
    end
  end

  describe "Encode request..." do
    it "starts encoding a new video" do
      xml = File.join(File.dirname(__FILE__), 'fixtures', 'encode.xml')
      FakeWeb.register_uri(:post, MoovAtom::API_URL, :body => xml)
      xml_res = @moov_engine.encode
      xml_res.must_equal "456"
    end
  end

  describe "Cancel request..." do
    it "cancels the encoding of an existing video" do
      xml = File.join(File.dirname(__FILE__), 'fixtures', 'cancel.xml')
      FakeWeb.register_uri(:post, MoovAtom::API_URL, :body => xml)
      xml_res = @moov_engine.cancel
      xml_res.body.must_include "<uuid>456</uuid>"
      xml_res.body.must_include "<message>This job was successfully cancelled.</message>"
    end
  end
end

