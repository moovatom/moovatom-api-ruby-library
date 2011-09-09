Introduction
============

[MoovAtom](http://moovatom.com/ "MoovAtom Homepage") is an online video conversion and streaming service. The service insulates your videos from competitor's ads or links to inappropriate content. It offers customizable players that support hot linkable watermarks in addition to stream paths to your own player so you can control your videos, and your brand, on your own terms. Streaming is supported to all Apple mobile devices as well as most Android and Blackberry platforms. A unique QR Code is generated for each video for use in advertisements, allowing your viewers to simply "scan and play" your content. Advanced analytics and metrics provide valuable incite into how your viewers are watching you videos. The MoovAtom servers support both FTP access and direct uploads so huge file sizes are easy to handle. MoovAtom makes it easy to protect your copyrights, the streaming servers provide unparalleled protection over other services using progressive downloads to a user's browser cache.


API
===

[MoovEngine](http://www.moovatom.com/support/api/1.0 "MoovEngine API") is the API interface to MoovAtom's servers and your video content. This library has been written to provide an easier interface for Ruby and Rails developers. The MoovAtom API utilizes a RESTful XML implementation. Simple XML requests are posted to MoovAtom's servers and XML responses are returned containing the various details about and status of your videos.


Overview
========
This library is wrapped in a module named MoovAtom. Inside the module there is a single class named MoovEngine. So to instantiate a new object to communicate with the MoovAtom API you simply need to call:

<code>
  require 'moovatom'  
  new_conn = MoovAtom::MoovEngine.new
</code>

Of course you can also simplify that code by using:

<code>
  require 'moovatom'  
  include MoovAtom  
  new_conn = MoovEngine.new
</code>

This code allows you to create a new instance without needing to enter the module's scope each time.

Installing the gem is as simple as `gem install moovatom`. However, this library is in an extreme alpha state so it may be best to access the gem via this GitHub repo. You can include a gem from its GitHub by adding the following to your app's Gemfile:

<code>
  gem 'moovatom', :git => "git://github.com/humanshell/moovatom.git"
</code>

There is a single module constant named `API_URL` that defines the URL to which the XML requests must be POST'd to. There are eight writable instance variables and one readable variable. The single readable variable is `@xml_response`. It's function is to hold the last response received from MoovAtom's servers. The other variables are as follows:

1. `@guid`
2. `@username`
3. `@userkey`
4. `@content_type`
5. `@title`
6. `@blurb`
7. `@sourcefile`
8. `@callbackurl`

These variables are used to communicate details about your account and your videos to MoovAtom's servers. You can define and pass them to the initialize method or set them after an object has been created with the usual accessor 'dot' notation:

<code>
  require 'moovatom'  
  include MoovAtom  
  args = { :title => "My Super Video", :sourcefile => "http://example.com/supervideo.mp4", etc... }
  new_conn = MoovEngine.new args
</code>

Or...

<code>
  require 'moovatom'  
  include MoovAtom  
  new_conn = MoovEngine.new  
  new_conn.title = "My Super Video"
  new_conn.sourcefile = "http://example.com/supervideo.mp4"
</code>


Encoding
========
Coming soon...


Status
======
Coming soon...


Details
=======
Coming soon...


Cancel
======
Coming soon...

