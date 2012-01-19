require "spec_helper"

# this file contains all the tests associated with instantiating a new
# MoovAtom::MoovEngine object

describe MoovAtom::MoovEngine, "Initialization Unit Tests" do

  it "sets the instance variables through a hash" do
    vars = {
      uuid: '123',
      username: 'jsmith',
      userkey: '987654321',
      content_type: 'video',
      title: 'My Great Movie',
      blurb: 'The greatest movie ever made',
      sourcefile: 'http://example.com/great.mp4',
      callbackurl: 'http://example.com/callback'
    }

    me = MoovAtom::MoovEngine.new vars

    me.uuid.must_equal '123'
    me.username.must_equal 'jsmith'
    me.userkey.must_equal '987654321'
    me.content_type.must_equal 'video'
    me.title.must_equal 'My Great Movie'
    me.blurb.must_equal 'The greatest movie ever made'
    me.sourcefile.must_equal 'http://example.com/great.mp4'
    me.callbackurl.must_equal 'http://example.com/callback'
  end

  it "sets the instance variables through a block" do
    me = MoovAtom::MoovEngine.new do |me|
      me.uuid = '123'
      me.username = 'jsmith'
      me.userkey = '987654321'
      me.content_type = 'video'
      me.title = 'My Great Movie'
      me.blurb = 'The greatest movie ever made'
      me.sourcefile = 'http://example.com/great.mp4'
      me.callbackurl = 'http://example.com/callback'
    end

    me.uuid.must_equal '123'
    me.username.must_equal 'jsmith'
    me.userkey.must_equal '987654321'
    me.content_type.must_equal 'video'
    me.title.must_equal 'My Great Movie'
    me.blurb.must_equal 'The greatest movie ever made'
    me.sourcefile.must_equal 'http://example.com/great.mp4'
    me.callbackurl.must_equal 'http://example.com/callback'
  end

  it "defaults to a content_type of video" do
    MoovAtom::MoovEngine.new.content_type.must_equal 'video'
  end

end
