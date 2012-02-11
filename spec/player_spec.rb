require "spec_helper"

# this file contains all the tests for editing the attributes of the video
# player on Moovatom's servers

describe MoovAtom::MoovEngine "Edit Player Request Unit Tests" do

  before do

    # mock up the connection to moovatom.com
    @url = "#{MoovAtom::API_URL}/edit_player"
    json_error = File.join(File.dirname(__FILE__), 'fixtures', 'player_error.json')
    FakeWeb.register_uri(:post, "#{@url}.json", :body => json_error)
    json_success = File.join(File.dirname(__FILE__), 'fixtures', 'player_success.json')
    FakeWeb.register_uri(:post, "#{@url}.json", :body => json_success)
    xml_error = File.join(File.dirname(__FILE__), 'fixtures', 'player_error.xml')
    FakeWeb.register_uri(:post, "#{@url}.xml", :body => xml_error)
    xml_success = File.join(File.dirname(__FILE__), 'fixtures', 'player_success.xml')
    FakeWeb.register_uri(:post, "#{@url}.xml", :body => xml_success)
  end

  after do
    # clean up the registry after each test
    FakeWeb.clean_registry

    # enable all real requests after testing
    FakeWeb.allow_net_connect = true
  end

  describe "API Requests" do
    
  end
  
end
