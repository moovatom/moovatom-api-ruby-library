require "spec_helper"

# this file contains all the tests for editing the attributes of the video
# player on Moovatom's servers

describe MoovAtom::MoovEngine, "Edit Player Request Unit Tests" do

  before do
    @pattrs1 = {
      username: "YOUR_MOOVATOM_USERNAME",
      userkey: "1a2b3c4d5e6f7g8h9i",
      uuid: "123",
      height: "480",
      width: "720",
      auto_play: false,
      sharing_enabled: true,
      show_hold_image: true,
      watermark: "http://www.example.com/path/to/watermark.png",
      watermark_url: "http://www.example.com",
      show_watermark: true,
      watermark_opacity: "0.8",
      background_color: "#000000",
      duration_color: "#FFFFFF",
      buffer_color: "#6C9CBC",
      volume_color: "#000000",
      volume_slider_color: "#000000",
      button_color: "#889AA4",
      button_over_color: "#92B2BD",
      time_color: "#01DAFF"
    }

    @pattrs2 = {
      username: "YOUR_MOOVATOM_USERNAME",
      userkey: "1a2b3c4d5e6f7g8h9i",
      uuid: "321",
      height: "720",
      width: "480",
      auto_play: true,
      sharing_enabled: false,
      show_hold_image: false,
      watermark: "http://www.example2.com/path/to/watermark.png",
      watermark_url: "http://www.example2.com",
      show_watermark: false,
      watermark_opacity: "0.4",
      background_color: "#000000",
      duration_color: "#FFFFFF",
      buffer_color: "#6C9CBC",
      volume_color: "#000000",
      volume_slider_color: "#000000",
      button_color: "#889AA4",
      button_over_color: "#92B2BD",
      time_color: "#01DAFF"
    }

    # mock up the connection to moovatom.com
    @me = MoovAtom::MoovEngine.new({userkey: "humanshell"}, @pattrs1)
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

  it "accepts a hash to update attributes" do

    # create a MoovEngine object using the values from the @vars1 hash
    me = MoovAtom::MoovEngine.new({username: "humanshell"}, @pattrs1)

    # call edit_player() passing the hash of values from @vars2
    me.edit_player @pattrs2

    # the instance 'me' should now contain the values from the @pattrs2 hash
    @pattrs2.each do |k,v|
      me.player.instance_variable_get("@table")[:"#{k}"].must_equal v
    end
  end

  it "accepts a block to update attributes" do

    # create a new MoovEngine object using a block
    me = MoovAtom::MoovEngine.new do |me|
      me.player.uuid = "123"
      me.player.height = "480"
      me.player.width = "720"
      me.player.auto_play = false
      me.player.sharing_enabled = true
      me.player.show_hold_image = true
      me.player.show_watermark = true
      me.player.watermark_opacity = "0.8"
    end

    # call edit_player() passing a block that sets player attributes
    me.edit_player do |me|
      me.player.uuid = "321"
      me.player.height = "720"
      me.player.width = "480"
      me.player.auto_play = true
      me.player.sharing_enabled = false
      me.player.show_hold_image = false
      me.player.show_watermark = false
      me.player.watermark_opacity = "0.4"
    end

    # the instance 'me' should now contain the values from the second block
    me.player.uuid.must_equal "321"
    me.player.height.must_equal "720"
    me.player.width.must_equal "480"
    me.player.auto_play.must_equal true
    me.player.sharing_enabled.must_equal false
    me.player.show_hold_image.must_equal false
    me.player.show_watermark.must_equal false
    me.player.watermark_opacity.must_equal "0.4"
  end

  it "sets the action attribute to edit_player" do

    # create a new MoovEngine object
    me = MoovAtom::MoovEngine.new({username: "humanshell"}, @pattrs1)

    # call the edit_player() method
    me.edit_player

    # after calling edit_player() @action should be 'edit_player'
    me.action.must_equal 'edit_player'
  end

  describe "API Requests" do
    
    it "edits a videos player using json" do
      @me.edit_player
      @me.response["uuid"].must_equal "123"
      @me.response["message"].must_equal "Player was edited successfully."
    end

    it "edits a videos player using xml" do
      @me.format = 'xml'
      @me.edit_player
      @me.response.root.elements["uuid"].text.must_equal "123"
      @me.response.root.elements["message"].text.must_equal "Player was edited successfully."
    end

  end
  
end
