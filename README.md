Introduction
============

[MoovAtom](http://moovatom.com/) is an online video conversion and streaming service. The service insulates your videos from competitor's ads or links to inappropriate content. It offers customizable players that support hot linkable watermarks in addition to stream paths to your own player so you can control your videos, and your brand, on your own terms. Streaming is supported to all Apple mobile devices as well as most Android and Blackberry platforms. A unique QR Code is generated for each video for use in advertisements, allowing your viewers to simply "scan and play" your content. Advanced analytics and metrics provide valuable incite into how your viewers are watching your videos. The MoovAtom servers support both FTP access and direct uploads so huge file sizes are easy to handle. MoovAtom makes it easy to protect your copyrights, the streaming servers provide unparalleled protection over other services using progressive downloads to a user's browser cache.


API
===

[MoovEngine](http://www.moovatom.com/support/api/1.0) is the API interface to MoovAtom's servers and your video content. This library has been written to provide an easier interface for Ruby and Rails developers. The MoovAtom API utilizes a RESTful XML implementation. Simple XML requests are posted to MoovAtom's servers and XML responses are returned containing the various details about and status of your videos.


Overview
========
This library is wrapped in a module named MoovAtom. Inside the module there is a single class named MoovEngine. So to instantiate a new object to communicate with the MoovAtom API you simply need to call:

```
require 'moovatom'  
new_conn = MoovAtom::MoovEngine.new
```

Of course you can also simplify that code by using:

```
require 'moovatom'  
include MoovAtom  
new_conn = MoovEngine.new
```

This code allows you to create a new instance without needing to enter the module's scope each time.

Installing the gem is as simple as `gem install moovatom`.

There is a single module constant named `API_URL` that defines the URL to which the XML requests must be POST'd. There are eight writable instance variables and one readable variable. The single readable variable is `@xml_response`. It's responsible for holding the last response received from MoovAtom's servers. The other variables are as follows:

1. `@guid`
2. `@username`
3. `@userkey`
4. `@content_type`
5. `@title`
6. `@blurb`
7. `@sourcefile`
8. `@callbackurl`

These variables are used to communicate details about your account and your videos to MoovAtom's servers. You can define and pass them to the initialize method or set them after an object has been created with the usual accessor 'dot' notation:

```
require 'moovatom'  
include MoovAtom  
args = { title: "My Super Video", sourcefile: "http://example.com/supervideo.mp4", etc... }  
new_conn = MoovEngine.new args
```

Or...

```
require 'moovatom'  
include MoovAtom  
new_conn = MoovEngine.new  
new_conn.title = "My Super Video"  
new_conn.sourcefile = "http://example.com/supervideo.mp4"
```

Encoding
========
To start a new encoding on Moovatom's servers you need to create a `MoovAtom::MoovEngine` object populated with the following information:

```
new_conn = MoovAtom::MoovEngine.new

new_conn.username = "MOOVATOM_USERNAME"
new_conn.userkey = "MOOVATOM_USERKEY"
new_conn.title = "The Greatest Movie Ever"
new_conn.blurb = "The gratest movie ever made!"
new_conn.sourcefile = "http://example.com/greatest_movie_ever.mp4"
new_conn.callbackurl = "/moovatom_callback"

new_conn.encode
```

The video you want to submit to Moovatom must be placed in a publicly accessible location. You should map the callback url to a controller that stores the uuid returned by the Moovatom servers into your database. You can use that uuid in the remaining request methods to access that specific encoding. Future versions of the gem will accept a block when instantiating a MoovEngine object.

For more specific instructions on using the Moovatom API please check their [documentation](http://www.moovatom.com/support/requests.html)

Status
======
Coming soon...


Details
=======
Coming soon...


Cancel
======
Coming soon...

