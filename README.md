![Moovatom Logo](http://www.moovatom.com/static/img/site_images/moovatom_logo.png)

Overview
========
This gem provides access to the Moovatom online video processing and streaming service. It provides all the necessary attributes and methods for:

1. Starting a new video encoding process
2. Getting the status of a current encoding
3. Getting the details of a completed encoding
4. Canceling an encoding job

Installing the gem is done through the usual `gem install moovatom` command, or by adding the following line to your project's Gemfile:

```
gem "moovatom", "~> 0.2.0"
```

The entire library is wrapped in a module named MoovAtom. Inside that module there is a single class named MoovEngine. This class defines one constant and 11 instance variables. The constant `API_URL` defines the URL to which the JSON or XML requests must be POST'd. The 11 instance variables are:

1. `@response`
2. `@action`
3. `@uuid`
4. `@username`
5. `@userkey`
6. `@content_type`
7. `@title`
8. `@blurb`
9. `@sourcefile`
10. `@callbackurl`
11. `@format`

The first 2 are readable only. `@response` will always contain the last response received from the Moovatom servers and `@action` will be set by each of the RESTful action methods explained below. The remaining 9 instance variables are writeable and correspond to the attributes of the video you want to control as well as your specific Moovatom account credentials. These attributes can be set in a number of ways depending on the needs of your specific application.

Instantiating a new (empty) object to communicate with the MoovAtom API is as simple as:

```ruby
require 'moovatom'
me = MoovAtom::MoovEngine.new
```

Of course you could simplify the above code if you plan on creating a lot of MoovEngine objects by including the MoovAtom module first:

```ruby
require 'moovatom'
include MoovAtom

me1 = MoovEngine.new

...1,000's of lines of code...

me2 = MoovEngine.new

...1,000's of lines of code...

etc...
```

The object created in the code above isn't very useful though. A MoovEngine object created without any arguments will, however, receive a few default values. `@content_type` will be initialized with a value of 'video' and `@format` will be set to 'json'. The remaining 7 instance variables need to be set with the credentials for your Moovatom account and the specifics about the video you wish to control. Aside from creating an empty object, as we did above, I've tried to include as much flexibility as I could when it comes to creating a new MoovEngine object. You can pass a hash to the initialize method containing the values you wish to be set. Any hash values that do not exist as instance variables will be ignored.

```ruby
me = MoovAtom::MoovEngine.new(uuid: '123', username: 'USERNAME', userkey: 123456789, etc...)
```

The initialize method will iterate over the hash and set each instance variable to the value you provide. You can supply numbers as regular numbers or as strings, the gem will convert all numbers to strings so they are formatted properly when sent to the Moovatom servers. In addition to supplying a hash you can also pass a block:

```ruby
me = MoovAtom::MoovEngine.new do |me|
  me.uuid = 123
  me.username = 'USERNAME'
  me.userkey = '123456789'
  etc...
end
```

The initialize method yields _itself_ giving the block access to the internal state of your new MoovEngine object. Because the hash arguments are processed first you can combine both techniques for maximum flexibility:

```ruby
me = MoovAtom::MoovEngine.new(uuid: '123', username: 'USERNAME', userkey: 123456789) do |me|
  me.title = 'Dolphin Training'
  me.blurb = 'How to train your dolphin like a pro.'
  me.sourcefile = 'http://example.com/dolphin.mp4'
  me.callbackurl = 'http://example.com/moovatom_callback'
end
```

Encoding
========

Status
======

Details
=======

Cancel
======

Testing
=======
This gem uses [Minitest](https://github.com/seattlerb/minitest), [Turn](https://github.com/TwP/turn) and [Fakeweb](https://github.com/chrisk/fakeweb) to implement specs for each of the above four request methods, pretty colorized output and for mocking up a connection to the API.

API
===

[MoovAtom](http://moovatom.com/) is an online video conversion and streaming service. The service insulates your videos from competitor's ads or links to inappropriate content. It offers customizable players that support hot linkable watermarks in addition to stream paths to your own player so you can control your videos, and your brand, on your own terms. Streaming is supported to all Apple mobile devices as well as most Android and Blackberry platforms. A unique QR Code is generated for each video for use in advertisements, allowing your viewers to simply "scan and play" your content. Advanced analytics and metrics provide valuable incite into how your viewers are watching your videos. The MoovAtom servers support both FTP access and direct uploads so huge file sizes are easy to handle. MoovAtom makes it easy to protect your copyrights, the streaming servers provide unparalleled protection over other services using progressive downloads to a user's browser cache.

[MoovEngine](http://moovatom.com/support/v2/api.html) is the API interface to MoovAtom's servers and your video content. This library has been written to provide an easier interface for Ruby and Rails developers. The MoovAtom API utilizes a RESTful JSON or XML implementation. Simple requests are posted to MoovAtom's servers and responses are returned containing the various details about and status of your videos.


