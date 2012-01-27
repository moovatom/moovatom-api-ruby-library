![Moovatom Logo](http://www.moovatom.com/static/img/site_images/moovatom_logo.png)

# Overview

This gem provides access to the Moovatom online video processing and streaming service. It provides all the necessary attributes and methods for:

1. Starting a new video encoding process
2. Getting the status of a current encoding
3. Getting the details of a completed encoding
4. Canceling an encoding job

Installing the gem is done through the usual `gem install moovatom` command, or by adding the following line to your project's Gemfile:

```
gem "moovatom", "~> 0.2.0"
```

The entire library is wrapped in a module named MoovAtom. Inside that module is a single class named MoovEngine. This class defines one constant, 11 instance variables and 4 action methods that interact with Moovatom's RESTful API. The constant `API_URL` defines the URL to which the JSON or XML requests must be POST'd. The 11 instance variables are:

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

The first 2 are readable only. `@response` will always contain the last response received from the Moovatom servers and `@action` will be set by each of the action methods explained below. The remaining 9 instance variables are writeable and correspond to the attributes of the video you want to control as well as your specific Moovatom account credentials. These attributes can be set in a number of ways depending upon the needs of your specific application.

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

etc...
```

The object created in the code above isn't very useful though. A MoovEngine object created without any arguments will, however, receive a few default values. `@content_type` will be initialized with a value of 'video' and `@format` will be set to 'json'. The remaining 7 instance variables need to be set with the credentials for your Moovatom account and the specifics about the video you wish to control. Aside from creating an empty object, as we did above, I've tried to include as much flexibility as I could when it comes to creating a new MoovEngine object. You can pass a hash to the initialize method containing the values you wish to be set. Any hash values that do not exist as instance variables will be ignored.

```ruby
me = MoovAtom::MoovEngine.new(uuid: 'j9i8h7g6f5e4d3c2b1a', username: 'USERNAME', userkey: 'a1b2c3d4e5f6g7h8i9j', etc...)
```

The initialize method will iterate over the hash and set each instance variable to the value you provide. In addition to supplying a hash you can also pass a block:

```ruby
me = MoovAtom::MoovEngine.new do |me|
  me.uuid = 'j9i8h7g6f5e4d3c2b1a'
  me.username = 'USERNAME'
  me.userkey = 'a1b2c3d4e5f6g7h8i9j'
  etc...
end
```

The initialize method yields _self_ giving the block access to the internal state of your new MoovEngine object. Because the hash arguments are processed first you can also combine both techniques for maximum flexibility:

```ruby
me = MoovAtom::MoovEngine.new(uuid: 'j9i8h7g6f5e4d3c2b1a', username: 'USERNAME') do |me|
  me.userkey = 'a1b2c3d4e5f6g7h8i9j'
  me.title = 'Dolphin Training'
  me.blurb = 'How to train your dolphin like a pro.'
  me.sourcefile = 'http://example.com/dolphin.mp4'
  me.callbackurl = 'http://example.com/moovatom_callback'
end
```

The gem has been designed to be highly customizable. You are free to create a single instance and reuse it throughout your code, changing the attributes each time you need to work with a different video, or multiple instances representing individual videos if that's what your application requires, it's completely up to you.

# Action Methods

The MoovEngine class has 4 methods that have been designed to interact directly with the RESTful API implemented by Moovatom's servers:

1. `get_details()` will return details about a video that has completed encoding
2. `get_status()` will return the status of a video (whether or not encoding has completed)
3. `encode()` will start a new encoding job
4. `cancel()` will cancel an unfinished encoding job

Each of these methods are almost identical. They all accept the same hash/block argument syntax as the initialize method. This allows you to easily reuse a MoovEngine object to request information about different videos. The 4 action methods are able to be used and reused because they share 2 additional methods that handle the heavy lifting when building and sending the request to Moovatom. These two methods are `build_request()` and `send_request()`. The first takes every instance variable and formats them as either a JSON or XML object (depending on the value of `@format`). The second is designed to take the object created by `build_request()` and POST it to the Moovatom servers. The return value of the `send_request()` method is a 'raw' Net::HTTP::Response object. This is again a design choice to leave the customization up to you and your app. Any of the 4 action methods below will return this response object so you have access to everything returned from Moovatom.

For more specific information about the Moovatom API please see the [documentation](http://moovatom.com/support/v2/api.html).

## Details

Getting the details of a video you've uploaded to your Moovatom account is as simple as creating a MoovEngine object and populating it with your credentials and the specifics of the movie you'd like to access:

```ruby
me = MoovAtom::MoovEngine.new do |me|
  me.uuid = 'j9i8h7g6f5e4d3c2b1a'
  me.username = 'USERNAME'
  me.userkey = 'a1b2c3d4e5f6g7h8i9j'
end

me.get_details

if me.response.code == 200 do
  video = Video.find(params[:id])
  video.update_attributes(JSON.parse(me.response.body))
else
  "...gracefully fail or raise an exception here..."
end
```

A details request will POST the uuid, username and userkey instance variables from your MoovEngine object using the `build_request()` and `send_request()` methods. If successful the body of the Moovatom response will contain the details of the video identified by the uuid set in your MoovEngine object:

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

Because the Net::HTTP::Response object is stored in the `@response` instance variable after every call you are able to make decisions in your code based on the specific response received from Moovatom. In the example above we only find and update a specific video if the status code from Moovatom is 200 (or 'OK'). This code is just an example - it hasn't been tested in a Rails or Rack app.

## Status

Sometimes you don't know if a large video you uploaded has finished encoding and you can't get its details until it's complete. `get_status()` allows you to query a video to find out if it's still processing or not.

```ruby
me = MoovAtom::MoovEngine.new do |me|
  me.uuid = 'j9i8h7g6f5e4d3c2b1a'
  me.username = 'USERNAME'
  me.userkey = 'a1b2c3d4e5f6g7h8i9j'
end

me.get_status

if me.response.code == 200 do
  json_res = JSON.parse(me.response.body)
  
  unless json_res['processing']
    video = Video.find(params[:id])
    video.update_attributes(json_res)
  end
else
  "...gracefully fail or raise an exception here..."
end
```

A status request will POST the uuid, username and userkey instance variables from your MoovEngine object using the `build_request()` and `send_request()` methods. The body of the Moovatom response will contain either a success or error response:

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

The example code above could potentially be the beginning of a controller that is responsible for showing videos. It can't display the details of a video that hasn't finished encoding so it uses `get_status()` to update the attributes of a video and then later on it can send a collection of those completed videos to a view. Again, this code is just an example - it hasn't been tested in a Rails or Rack app.

## Encode

## Cancel

If you decide, for whatever reason, that you no longer need or want a specific video on Moovatom you can cancel its encoding anytime __before it finishes__ using the `cancel()` method. A cancel request will POST the uuid, username and userkey instance variables from your MoovEngine object using the `build_request()` and `send_request()` methods. The body of the Moovatom response will contain a message telling you whether or not you successfully cancelled your video:

```ruby
me = MoovAtom::MoovEngine.new do |me|
  me.uuid = 'j9i8h7g6f5e4d3c2b1a'
  me.username = 'USERNAME'
  me.userkey = 'a1b2c3d4e5f6g7h8i9j'
end

me.get_status

if me.response.code == 200 do
  json_res = JSON.parse(me.response.body)
  
  if json_res['processing']
    me.cancel
  end
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

*__NOTE:__ There is currently no way to delete a video from your Moovatom account that has completed encoding without manually logging in and delete the it yourself. The ability to delete through the API will be available in future versions of the API.*

# Testing

This gem uses [Minitest](https://github.com/seattlerb/minitest), [Turn](https://github.com/TwP/turn) and [Fakeweb](https://github.com/chrisk/fakeweb) to implement specs for each of the above four request methods, pretty colorized output and for mocking up a connection to the API.

The entire test suite is under the spec directory. The `spec_helper.rb` file contains the common testing code and gets required by each `*_spec.rb` file. There is one spec file (`init_spec.rb`) that tests all of the expected functionality related to initializing a new MoovEngine object. Each of the 4 action methods also has a single spec file dedicated to testing it's expected functionality. All API requests are mocked through [Fakeweb](https://github.com/chrisk/fakeweb) and the responses come from the files in the fixtures directory.

The Rakefile's default task is 'minitest', which will load and execute all the `*_spec.rb` files in the spec directory. So a simple call to `rake` on the command line from the project's root directory will run the entire test suite.

This is the first Ruby project in which I started from a TDD/BDD design perspective. If anyone has a problem with the tests or sees areas where I can improve please [open an issue](https://github.com/humanshell/moovatom/issues) here so it can be discussed and everyone can learn a little. I really enjoyed creating tests that helped drive the design of the code. I'm sure there are *PLENTY* of areas in which I can improve.

# Moovatom

[MoovAtom](http://moovatom.com/) is an online video conversion and streaming service. The service insulates your videos from competitor's ads or links to inappropriate content. It offers customizable players that support hot linkable watermarks in addition to stream paths to your own player so you can control your videos, and your brand, on your own terms. Streaming is supported to all Apple mobile devices as well as most Android and Blackberry platforms. A unique QR Code is generated for each video for use in advertisements, allowing your viewers to simply "scan and play" your content. Advanced analytics and metrics provide valuable incite into how your viewers are watching your videos. The MoovAtom servers support both FTP access and direct uploads so huge file sizes are easy to handle. MoovAtom makes it easy to protect your copyrights, the streaming servers provide unparalleled protection over other services using progressive downloads to a user's browser cache.

For more specific information about the Moovatom API please see the [documentation](http://moovatom.com/support/v2/api.html).
