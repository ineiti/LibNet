#!/usr/bin/ruby -w

require 'test/unit'

class TC_users < Test::Unit::TestCase
  def setup
    $lib_net.call :captive_setup
    `mkdir -p run log`
    `rm run/* log/*`
  end
  
  def test_connect
    assert_equal "", $lib_net.call( :users_connected )

    $lib_net.call_args( :user_connect, "1.1.1.1 foo" )
    assert_equal "foo", $lib_net.call( :users_connected )
    assert_equal "yes", $lib_net.call( :isp_connected )

    $lib_net.call_args( :user_connect, "1.1.1.1 bar" )
    assert_equal "bar", $lib_net.call( :users_connected )
    assert_equal "yes", $lib_net.call( :isp_connected )

    $lib_net.call_args( :user_connect, "1.1.1.2 bar" )
    assert_equal "bar", $lib_net.call( :users_connected )
    assert_equal "yes", $lib_net.call( :isp_connected )

    $lib_net.call_args( :user_disconnect, "1.1.1.1 bar" )
    assert_equal "", $lib_net.call( :users_connected )
    assert_equal "no", $lib_net.call( :isp_connected )
  end
end