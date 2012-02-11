require "spec_helper"

# this file contains all the tests associated with instantiating a new
# MoovAtom::MoovEngine object

describe MoovAtom::MoovEngine, "Initialization Unit Tests" do

  before do
    @vattrs = {
      uuid: '123',
      username: 'jsmith',
      userkey: '987654321',
      title: 'My Great Movie',
      blurb: 'The greatest movie ever made',
      sourcefile: 'http://example.com/great.mp4',
      callbackurl: 'http://example.com/callback'
    }

    @pattrs = {
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
  end

  it "sets video attributes through a hash" do
    me = MoovAtom::MoovEngine.new @vattrs
    @vattrs.each {|k,v| me.instance_variable_get("@#{k}").must_equal v}
  end

  it "sets player attributes through a hash" do
    me = MoovAtom::MoovEngine.new @vattrs, @pattrs

    @pattrs.each {|k,v| me.player.instance_variable_get("@table")[k].must_equal v}
  end

  it "sets video attributes through a block" do
    me = MoovAtom::MoovEngine.new do |me|
      @vattrs.each {|k,v| me.instance_variable_set "@#{k}", v}
    end

    @vattrs.each {|k,v| me.instance_variable_get("@#{k}").must_equal v}
  end

  it "sets player attributes through a block" do
    me = MoovAtom::MoovEngine.new do |me|
      me.player.height = @pattrs[:height]
      me.player.width = @pattrs[:width]
      me.player.time_color = @pattrs[:time_color]
    end

    me.player.height.must_equal @pattrs[:height]
    me.player.width.must_equal @pattrs[:width]
    me.player.time_color.must_equal @pattrs[:time_color]
  end

  it "defaults to a content_type of video" do
    MoovAtom::MoovEngine.new.content_type.must_equal 'video'
  end

  it "defaults to a format of json" do
    MoovAtom::MoovEngine.new.format.must_equal 'json'
  end

end
