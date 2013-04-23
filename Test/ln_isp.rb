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
  
  def test_set_vars
    assert_equal "{\"cost_base\":5,\"cost_shared\":10\\)", $lib_net.call( :isp_cost_get )

    $lib_net.call_args( :isp_cost_set, "20 30" )
    assert_equal "{\"cost_base\":20,\"cost_shared\":30\\)", $lib_net.call( :isp_cost_get )
  end
end
