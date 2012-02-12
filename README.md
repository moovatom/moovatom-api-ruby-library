![Moovatom Logo](http://www.moovatom.com/static/img/site_images/moovatom_logo.png)

*__NOTE:__ As of version 0.2.0 this gem no longer supports v1 of the Moovatom API. That version has been deprecated. It is highly recommended that you move to the new v2 API as soon as possible.*

# Overview

This gem provides access to the Moovatom online video processing and streaming service. It provides all the necessary attributes and methods for:

1. Starting a new video encoding process
2. Getting the status of a current encoding
3. Getting the details of a completed encoding
4. Canceling an encoding job
5. Editing the attributes of your video player

Installing the gem is done through the usual `gem install moovatom` command, or by adding the following line to your project's Gemfile:

```
gem "moovatom", "~> 0.2.0"
```

The entire library is wrapped in a module named MoovAtom. Inside that module is a single class named MoovEngine. This class defines one constant, 12 instance variables and five action methods that interact with Moovatom's RESTful API. The constant `API_URL` defines the URL to which the JSON or XML requests must be POST'd. The 12 instance variables are:

1. `@uuid`
2. `@username`
3. `@userkey`
4. `@content_type`
5. `@title`
6. `@blurb`
7. `@sourcefile`
8. `@callbackurl`
9. `@format`
10. `@player`
11. `@action`
12. `@response`

The last 2 are readable only. `@response` will always contain the last response received from the Moovatom servers and `@action` will be set by each of the action methods explained below. `@player` is a struct object (technically an OpenStruct) that provides access to the player attributes for your video. The remaining 9 instance variables are writeable and correspond to the attributes of the video you want to control as well as your specific Moovatom account credentials. These attributes can be set in a number of ways depending upon the needs of your specific application.

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

...thousands of lines of code...

me2 = MoovEngine.new

...thousands of lines of code...

me3 = MoovEngine.new

etc...
```

The object created in the code above isn't very useful though. A MoovEngine object created without any arguments will, however, receive a few default values. `@content_type` will be initialized with a value of 'video', `@format` will be set to 'json' and `@player` will be initialized as an empty struct if no argument or block parameters are provided. The remaining 9 instance variables need to be set with the credentials for your Moovatom account and the specifics about the video you wish to control. Aside from creating an empty object, as we did above, I've tried to include as much flexibility as I could when it comes to creating a new MoovEngine object. You can pass one or two hashes to the initialize method containing the values you wish to be set for either player or video attributes. The first hash will be used to setup video attributes and your Moovatom account credentials. The second hash is used to initialize an OpenStruct object of player attributes.

```ruby
// You can pass literal hashes:
me = MoovAtom::MoovEngine.new({uuid: 'j9i8h7g6f5e4d3c2b1a'}, {height: '480'})

// But it may be more readable to create the hashes first and then pass them:
vattrs = {uuid: 'j9i8h7g6f5e4d3c2b1a', username: 'USERNAME', etc...}
pattrs = {width: "720", height: "480", etc...}
me = MoovAtom::MoovEngine.new(vattrs, pattrs)
```

The initialize method will first create an OpenStruct object using the values from the second hash if it was supplied and then iterate over the first hash and set each instance variable to the values provided. In addition to supplying a hash you can also pass a block:

```ruby
me = MoovAtom::MoovEngine.new do |me|
  me.uuid = 'j9i8h7g6f5e4d3c2b1a'
  me.username = 'USERNAME'
  me.userkey = 'a1b2c3d4e5f6g7h8i9j'
  me.player.height = "480"
  me.player.width = "720"
  etc...
end
```

The initialize method yields _self_ giving the block access to the internal state of your new MoovEngine object. Because the hash arguments are processed first you can also combine both techniques for maximum flexibility:

```ruby
me = MoovAtom::MoovEngine.new({uuid: 'j9i8h7g6f5e4d3c2b1a'}, {width: '720'}) do |me|
  me.userkey = 'a1b2c3d4e5f6g7h8i9j'
  me.title = 'Dolphin Training'
  me.blurb = 'How to train your dolphin like a pro.'
  me.sourcefile = 'http://example.com/dolphin.mp4'
  me.callbackurl = 'http://example.com/moovatom_callback'
  me.player.height = "480"
end
```

The gem has been designed to be highly customizable. You are free to create a single instance and reuse it throughout your code, changing the attributes each time you need to work with a different video, or multiple instances representing individual videos if that's what your application requires, it's completely up to you.

# Action Methods

The MoovEngine class has five methods that have been designed to interact directly with the RESTful API implemented by Moovatom's servers:

1. `get_details()` will return details about a video that has __completed__ encoding
2. `get_status()` will return the status of a video (whether or not encoding has completed)
3. `encode()` will start a new encoding job
4. `cancel()` will cancel an unfinished encoding job
5. `edit_player()` changes the attributes of your video's online player

Each of these methods are almost identical. They all accept a hash/block argument syntax similar to the initialize method. The main difference is that the action methods will accept only one hash and a block. This allows you to easily reuse a MoovEngine object to request information about different videos. The five action methods are able to be used and reused because they share a method that handles the heavy lifting when building and sending the request to Moovatom: `send_request()`. The `send_request()` method takes every instance variable (including player attributes) and creates a hash of the key/value attributes for your video. It then uses the `@format` and `@action` instance variables to build and POST the appropriate request to the Moovatom servers. If the response is successful it will parse it into either JSON or XML and store it in the `@response` instance variable. If the response is anything other than "200 OK" the raw Net::HTTPResponse object will be passed through and stored in `@response`. This allows you and your app to determine how best to handle the specific error response.

For more specific information about the Moovatom API please see the [documentation](http://moovatom.com/support/v2/api.html).

## Details

Getting the details of a video you've uploaded to your Moovatom account is as simple as creating a MoovEngine object and populating it with your credentials and the specifics of the video you'd like to access:

```ruby
me = MoovAtom::MoovEngine.new(uuid: 'j9i8h7g6f5e4d3c2b1a') do |me|
  me.username = 'USERNAME'
  me.userkey = 'a1b2c3d4e5f6g7h8i9j'
end

me.get_details

if me.response["uuid"] == 'j9i8h7g6f5e4d3c2b1a'
  video = Video.find(params[:id])
  video.update_attributes(me.response)
else
  "...gracefully fail or raise an exception here..."
end
```

A details request will POST the uuid, username and userkey instance variables from your MoovEngine object using the `send_request()` method. If successful `@response` will contain either a JSON or XML formatted object (depending on the value of `@format`) ready to be queried and used. The example above shows how you can pass a hash, a block or both to the method. The remaining four action methods all accept the same style of argument passing.

*Successful get_details() JSON Response:*

```
{
    "uuid": "UUID",
    "media_type": "video",
    "embed_code": "EMBED CODE SMART SWITCHING FOR AUTOMATIC MOBILE AND WEB SUPPORT.",
    "iframe_target": "http://www.moovatom.com/media/embed/ID",
    "original_download": "http://www.moovatom.com/media/download/orig/UUID",
    "versions": [
        {
            "name": "mobile",
            "type": "video/mp4",
            "holdframe_download": "http://www.moovatom.com/PATH_TO_FILE",
            "thumbnail_download": "http://www.moovatom.com/PATH_TO_FILE",
            "holdframe_serve": "http://static.moovatom.com/PATH_TO_FILE",
            "thumbnail_serve": "http://static.moovatom.com/PATH_TO_FILE",
            "rtmp_stream": "rtmp://media.moovatom.com/PATH_TO_FILE",
            "http_stream": "http://media.moovatom.com:1935/PATH_TO_FILE",
            "rtsp_stream": "rtsp://media.moovatom.com:1935/PATH_TO_FILE",
            "download": "http://www.moovatom.com/PATH_TO_FILE"
        },
        {
            "name": "mobile_large",
            "type": "video/mp4",
            "holdframe_download": "http://www.moovatom.com/PATH_TO_FILE",
            "thumbnail_download": "http://www.moovatom.com/PATH_TO_FILE",
            "holdframe_serve": "http://static.moovatom.com/PATH_TO_FILE",
            "thumbnail_serve": "http://static.moovatom.com/PATH_TO_FILE",
            "rtmp_stream": "rtmp://media.moovatom.com/PATH_TO_FILE",
            "http_stream": "http://media.moovatom.com:1935/PATH_TO_FILE",
            "rtsp_stream": "rtsp://media.moovatom.com:1935/PATH_TO_FILE",
            "download": "http://www.moovatom.com/PATH_TO_FILE"
        },
        {
            "name": "small",
            "type": "video/mp4",
            "holdframe_download": "http://www.moovatom.com/PATH_TO_FILE",
            "thumbnail_download": "http://www.moovatom.com/PATH_TO_FILE",
            "holdframe_serve": "http://static.moovatom.com/PATH_TO_FILE",
            "thumbnail_serve": "http://static.moovatom.com/PATH_TO_FILE",
            "rtmp_stream": "rtmp://media.moovatom.com/PATH_TO_FILE",
            "http_stream": "http://media.moovatom.com:1935/PATH_TO_FILE",
            "rtsp_stream": "rtsp://media.moovatom.com:1935/PATH_TO_FILE",
            "download": "http://www.moovatom.com/PATH_TO_FILE"
        },
        {
            "name": "medium",
            "type": "video/mp4",
            "holdframe_download": "http://www.moovatom.com/PATH_TO_FILE",
            "thumbnail_download": "http://www.moovatom.com/PATH_TO_FILE",
            "holdframe_serve": "http://static.moovatom.com/PATH_TO_FILE",
            "thumbnail_serve": "http://static.moovatom.com/PATH_TO_FILE",
            "rtmp_stream": "rtmp://media.moovatom.com/PATH_TO_FILE",
            "http_stream": "http://media.moovatom.com:1935/PATH_TO_FILE",
            "rtsp_stream": "rtsp://media.moovatom.com:1935/PATH_TO_FILE",
            "download": "http://www.moovatom.com/PATH_TO_FILE"
        },
        {
            "name": "large",
            "type": "video/mp4",
            "holdframe_download": "http://www.moovatom.com/PATH_TO_FILE",
            "thumbnail_download": "http://www.moovatom.com/PATH_TO_FILE",
            "holdframe_serve": "http://static.moovatom.com/PATH_TO_FILE",
            "thumbnail_serve": "http://static.moovatom.com/PATH_TO_FILE",
            "rtmp_stream": "rtmp://media.moovatom.com/PATH_TO_FILE",
            "http_stream": "http://media.moovatom.com:1935/PATH_TO_FILE",
            "rtsp_stream": "rtsp://media.moovatom.com:1935/PATH_TO_FILE",
            "download": "http://www.moovatom.com/PATH_TO_FILE"
        }
    ]
}
```


## Status

Sometimes you don't know if a large video you've uploaded has finished encoding and you can't get its details until it's complete. `get_status()` allows you to query a video to find out if it's still processing.

```ruby
me = MoovAtom::MoovEngine.new(uuid: 'j9i8h7g6f5e4d3c2b1a') do |me|
  me.username = 'USERNAME'
  me.userkey = 'a1b2c3d4e5f6g7h8i9j'
end

me.get_status

unless me.response["processing"]
  me.get_details
  
  if me.response["uuid"] == 'j9i8h7g6f5e4d3c2b1a'
    video = Video.find(params[:id])
    video.update_attributes(me.response)
  else
    "...gracefully fail or raise an exception here..."
  end
end
```

A status request will POST the uuid, username and userkey instance variables from your MoovEngine object using the `send_request()` method. The `@response` variable will contain either a success or error response:

*Status Success Response:*

```
{
    "uuid": "UUID",
    "processing": true,
    "percent_complete": 75,
    "error": 
}
```

*Status Error Response:*

```
{
    "uuid": "UUID",
    "processing": false,
    "percent_complete": 100,
    "error": "This was not a recognized format."
}
```

## Encode

You can start a new encoding on the Moovatom servers through the `encode()` method.

```ruby
me = MoovAtom::MoovEngine.new(userkey: 'a1b2c3d4e5f6g7h8i9j') do |me|
  me.username = 'USERNAME'
  me.title = 'Dolphin Training'
  me.blurb = 'How to train your dolphin like a pro.'
  me.sourcefile = 'http://example.com/dolphin.mp4'
  me.callbackurl = 'http://example.com/moovatom_callback'
end

me.encode
```

An encode request will POST the username, userkey, content_type, title, blurb, sourcefile and callbackurl instance variables from your MoovEngine object using the `send_request()` method. The body of the Moovatom response will contain the uuid assigned by Moovatom's servers to this new video as well as a message stating your job was started successfully:

*Encode Started Response:*

```
{
    "uuid": "UUID",
    "message": "Your job was started successfully."
}
```

After a successful response the `@uuid` variable of your MoovEngine object will be set to the uuid assigned by Moovatom. The encode action implemented on Moovatom's servers differs slightly from the other three actions. Once the encoding is complete Moovatom's servers will send a response to the call back URL you set in the `@callbackurl` instance variable. Your app should define a controller (or url handler if it's a [Sinatra](http://www.sinatrarb.com/) app) that will process these callbacks to save/update the video's details in your database. The body of the callback sent by Moovatom looks exactly like the response from a `get_details()` request.

Additionally, the video you are uploading to Moovatom must be in a publicly accessibly location. Moovatom will attempt to transfer that video from the url you define in the `@sourcefile` instance variable. The ability to upload a video directly is planned for a future version of the API and this gem.

For more specific information about the Moovatom API please see the [documentation](http://moovatom.com/support/v2/api.html).

## Cancel

If you decide, for whatever reason, that you no longer need or want a specific video on Moovatom you can cancel its encoding anytime __before it finishes__ using the `cancel()` method. A cancel request will POST the uuid, username and userkey instance variables from your MoovEngine object using the `send_request()` method. The body of the Moovatom response will contain a message telling you whether or not you successfully cancelled your video:

```ruby
me = MoovAtom::MoovEngine.new(uuid: 'j9i8h7g6f5e4d3c2b1a') do |me|
  me.username = 'USERNAME'
  me.userkey = 'a1b2c3d4e5f6g7h8i9j'
end

me.get_status

if me.response['processing']
  me.cancel
else
  "...gracefully fail or raise an exception here..."
end
```

*Example cancel request response:*

```
{
    "uuid": "UUID",
    "message": "This job was successfully cancelled."
}
```

*__NOTE:__ There is currently no way to delete a video from your Moovatom account that has completed encoding without manually logging in and deleting it yourself. The ability to delete through the API will be available in the future.*

## Edit Player

The true power of Moovatom's streaming service becomes apparent only after you've placed a video on your site through their iframe code. But sometimes you need a little more control over how your video plays and what it looks like. This is where the `edit_player()` action method comes in. There are 17 attributes you can control through the API (shown below with their default values):

```
height: 480
width: 720
auto_play: False
sharing_enabled: True
show_hold_image: True
watermark: http://www.example.com/path/to/watermark.png
watermark_url: http://www.example.com
show_watermark: True
watermark_opacity: 0.8
background_color: #000000
duration_color: #FFFFFF
buffer_color: #6C9CBC
volume_color: #000000
volume_slider_color: #000000
button_color: #889AA4
button_over_color: #92B2BD
time_color: #01DAFF
```

The `edit_player()` method accepts the same hash/block argument syntax as the first four action methods, however, it takes the hash you pass and merges those attributes into any previous ones supplied in the second hash passed to the initialize method. Since the `@player` instance variable is just an OpenStruct object you can set any of the attributes above manually or through a block as well.

```ruby
Variables can be set with a hash or a block or both:
attrs = {width: "800", height: "500"}
me.edit_player(attrs) do |me|
  me.player.time_color = #12EBGG
end


me.player.watermark = "http://www.example.com/path/to/watermark.png"
me.player.watermark_url = "http://www.example.com"
me.player.show_watermark = true
```

You can always add an attribute to your player struct by calling into it through the player instance variable:

```ruby
me = MoovAtom::MoovEngine.new
me.player.height = "480"
me.player.width = "720"
me.player.auto_play = false
me.player.sharing_enabled = true
me.player.watermark_opacity = "0.8"
me.player.background_color = "#000000"
me.player.duration_color = "#FFFFFF"
me.player.volume_color = "#000000"
me.player.button_color = "#889AA4"
me.player.time_color = "#01DAFF"
```

Since `@player` is implemented an an OpenStruct object it will create the attributes dynamically as you need them. This way only the attributes you which to alter will be sent in your requests.

For more specific information about the Moovatom API please see the [documentation](http://moovatom.com/support/v2/api.html).

# Testing

Development of this gem was done on Ruby 1.9.2-p290. There should be no problems on 1.9.3. I haven't tried it on Ruby 1.8.7, but you shouldn't be using 1.8.7 anyways.  :-)

This gem uses [Minitest](https://github.com/seattlerb/minitest), [Turn](https://github.com/TwP/turn) and [Fakeweb](https://github.com/chrisk/fakeweb) to implement specs for each of the above four request methods, pretty colorized output and for mocking up a connection to the API.

The entire test suite is under the spec directory. The `spec_helper.rb` file contains the common testing code and gets required by each `*_spec.rb` file. There is one spec file (`init_spec.rb`) that tests the expected functionality related to initializing a new MoovEngine object. Each of the 4 action methods also has a single spec file dedicated to testing its expected functionality. All API requests are mocked through [Fakeweb](https://github.com/chrisk/fakeweb) and the responses come from the files in the fixtures directory.

The Rakefile's default task is 'minitest', which will load and execute all the `*_spec.rb` files in the spec directory. So a simple call to `rake` on the command line from the project's root directory will run the entire test suite.

This is the first Ruby project in which I started from a TDD/BDD design perspective. If anyone has a problem with the tests or sees areas where I can improve please [open an issue](https://github.com/humanshell/moovatom/issues) here so it can be discussed and everyone can learn a little. I really enjoyed creating tests that helped drive the design of the code. I'm sure there are *PLENTY* of areas in which I can improve.

# Moovatom

[MoovAtom](http://moovatom.com/) is an online video conversion and streaming service. The service insulates your videos from competitor's ads or links to inappropriate content. It offers customizable players that support hot linkable watermarks in addition to stream paths to your own player so you can control your videos, and your brand, on your own terms. Streaming is supported to all Apple mobile devices as well as most Android and Blackberry platforms. A unique QR Code is generated for each video for use in advertisements, allowing your viewers to simply "scan and play" your content. Advanced analytics and metrics provide valuable incite into how your viewers are watching your videos. The MoovAtom servers support both FTP access and direct uploads so huge file sizes are easy to handle. MoovAtom makes it easy to protect your copyrights, the streaming servers provide unparalleled protection over other services using progressive downloads to a user's browser cache.

For more specific information about the Moovatom API please see the [documentation](http://moovatom.com/support/v2/api.html).
