#!/usr/bin/ruby -w

require 'test/unit'

class TC_isp < Test::Unit::TestCase
  def setup
  end
  
  def test_init
    libnet = LibNet.new
  end
end
