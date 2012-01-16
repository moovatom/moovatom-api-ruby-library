gem "minitest"
require "minitest/autorun"
require "turn"
require "fakeweb"
require "moovatom"

# disable all real requests while in testing mode
FakeWeb.allow_net_connect = false

