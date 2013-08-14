#!/usr/bin/ruby -w

require 'test/unit'

class TC_isp < Test::Unit::TestCase
  def setup
    $lib_net.call :captive_setup
    `mkdir -p run log`
    `rm run/* log/*`
    `cp ../multiconf-captive.orig multiconf-captive`
    $lib_net.call_args( :change_var, "multiconf-captive ISP test" )
  end
  
  def test_to_json
    assert_equal "{\"one\":1,\"two\":2\\)", 
      $lib_net.call_args( :to_json, "one 1 two 2" )

    assert_equal "", 
      JSON.parse( $lib_net.call_args( :to_json, "one 1 two 2" ) ).to_sym
  end
end
