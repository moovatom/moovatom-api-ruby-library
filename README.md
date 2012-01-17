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

response = new_conn.encode
```

The video you want to submit to Moovatom must be placed in a publicly accessible location. You should map the callback url to a controller that stores the uuid returned by the Moovatom servers into your database. You can use that uuid in the remaining request methods to access that specific encoding. Future versions of the gem will accept a block when instantiating a MoovEngine object.

Status
======
To retrieve the status of an existing encoding on Moovatom's servers you need a `MoovAtom::MoovEngine` object populated with the following information:

```
new_conn = MoovAtom::MoovEngine.new

new_conn.username = "MOOVATOM_USERNAME"
new_conn.userkey = "MOOVATOM_USERKEY"
new_conn.uuid = "UUID_OF_VIDEO"

response = new_conn.status
```

The Moovatom servers will respond one of two ways:

Success:

```
<?xml version="1.0"?>      
<response>
  <uuid>UUID</uuid>
  <processing>True</processing>
  <percent_complete>75</percent_complete>
  <error></error>
</response>
```

Error:

```
<?xml version="1.0"?>    
<response>
  <uuid>UUID</uuid>
  <processing>False</processing>
  <percent_complete>100</percent_complete>
  <error>This was not a recognized format.</error>
</response>  
```

Details
=======
When you need to get the details about an encoding that has finished on Moovatom's server you need a `MoovAtom::MoovEngine` object populated with the following information:

```
new_conn = MoovAtom::MoovEngine.new

new_conn.username = "MOOVATOM_USERNAME"
new_conn.userkey = "MOOVATOM_USERKEY"
new_conn.uuid = "UUID_OF_VIDEO"

response = new_conn.details
```

The response from a request for details contains the same information returned to the `@callbackurl` when an encoding completes:

```
<?xml version="1.0"?>
<response>
    <uuid>UUID</uuid>
    <media_type>video</media_type>
    <embed_code>EMBED CODE IFRAME FOR SMART SWITCHING</embed_code>
    <iframe_target>http://www.moovatom.com/media/embed/SHORTID</iframe_target>
    <original_download>http://www.moovatom.com/media/download/orig/UUID</original_download>
    <versions>
        <version>
            <name>mobile</name>
            <type>video/mp4</type>
            <holdframe_download>http://www.moovatom.com/PATH_TO_FILE</holdframe_download>
            <thumbnail_download>http://www.moovatom.com/PATH_TO_FILE</thumbnail_download>
            <holdframe_serve>http://static.moovatom.com/PATH_TO_FILE</holdframe_serve>
            <thumbnail_serve>http://static.moovatom.com/PATH_TO_FILE</thumbnail_serve>
            <rtmp_stream>rtmp://media.moovatom.com/PATH_TO_FILE</rtmp_stream>
            <http_stream>http://media.moovatom.com:1935/PATH_TO_FILE</http_stream>
            <rtsp_stream>rtsp://media.moovatom.com:1935/PATH_TO_FILE</rtsp_stream>
            <download>http://www.moovatom.com/PATH_TO_FILE</download>
        </version>
        <version>
            <name>small</name>
            <type>video/mp4</type>
            <holdframe_download>http://www.moovatom.com/PATH_TO_FILE</holdframe_download>
            <thumbnail_download>http://www.moovatom.com/PATH_TO_FILE</thumbnail_download>
            <holdframe_serve>http://static.moovatom.com/PATH_TO_FILE</holdframe_serve>
            <thumbnail_serve>http://static.moovatom.com/PATH_TO_FILE</thumbnail_serve>
            <rtmp_stream>rtmp://media.moovatom.com/PATH_TO_FILE</rtmp_stream>
            <http_stream>http://media.moovatom.com:1935/PATH_TO_FILE</http_stream>
            <rtsp_stream>rtsp://media.moovatom.com:1935/PATH_TO_FILE</rtsp_stream>
            <download>http://www.moovatom.com/PATH_TO_FILE</download>
        </version>
        <version>
            <name>medium</name>
            <type>video/mp4</type>
            <holdframe_download>http://www.moovatom.com/PATH_TO_FILE</holdframe_download>
            <thumbnail_download>http://www.moovatom.com/PATH_TO_FILE</thumbnail_download>
            <holdframe_serve>http://static.moovatom.com/PATH_TO_FILE</holdframe_serve>
            <thumbnail_serve>http://static.moovatom.com/PATH_TO_FILE</thumbnail_serve>
            <rtmp_stream>rtmp://media.moovatom.com/PATH_TO_FILE</rtmp_stream>
            <http_stream>http://media.moovatom.com:1935/PATH_TO_FILE</http_stream>
            <rtsp_stream>rtsp://media.moovatom.com:1935/PATH_TO_FILE</rtsp_stream>
            <download>http://www.moovatom.com/PATH_TO_FILE</download>
        </version>
        <version>
            <name>large</name>
            <type>video/mp4</type>
            <holdframe_download>http://www.moovatom.com/PATH_TO_FILE</holdframe_download>
            <thumbnail_download>http://www.moovatom.com/PATH_TO_FILE</thumbnail_download>
            <holdframe_serve>http://static.moovatom.com/PATH_TO_FILE</holdframe_serve>
            <thumbnail_serve>http://static.moovatom.com/PATH_TO_FILE</thumbnail_serve>
            <rtmp_stream>rtmp://media.moovatom.com/PATH_TO_FILE</rtmp_stream>
            <http_stream>http://media.moovatom.com:1935/PATH_TO_FILE</http_stream>
            <rtsp_stream>rtsp://media.moovatom.com:1935/PATH_TO_FILE</rtsp_stream>
            <download>http://www.moovatom.com/PATH_TO_FILE</download>
        </version>
    </versions>
</response>
```

Cancel
======
To cancel an unfinished encoding on Moovatom's servers you need a `MoovAtom::MoovEngine` object populated with the following information:

```
new_conn = MoovAtom::MoovEngine.new

new_conn.username = "MOOVATOM_USERNAME"
new_conn.userkey = "MOOVATOM_USERKEY"
new_conn.uuid = "UUID_OF_VIDEO"

response = new_conn.cancel
```

A successful cancellation results in the following response:

```
<?xml version="1.0"?>   
<response>
  <uuid>UUID</uuid>
  <message>This job was successfully cancelled.</message>
</response>
```

For more specific instructions on using the Moovatom API please check the [documentation](http://www.moovatom.com/support/requests.html)

Testing
=======

