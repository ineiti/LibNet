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
    $lib_net.call_args( :isp_connection_status_set, 4 )
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
  
  def test_end_promotion
    $lib_net.call_args( :user_connect, "1.1.1.1 foo" )
    $lib_net.call_args( :isp_connection_status_set, 4 )
    assert_equal "foo", $lib_net.call( :users_connected )
    assert_equal "yes", $lib_net.call( :isp_connected )

    $lib_net.call :captive_cleanup
    assert_equal "foo", $lib_net.call( :users_connected )
    assert_equal "yes", $lib_net.call( :isp_connected )

    $lib_net.call_args( :isp_connection_status_set, 0 )
    $lib_net.call :captive_cleanup
    assert_equal "", $lib_net.call( :users_connected )
    assert_equal "no", $lib_net.call( :isp_connected )
  end
  
  # Well, this is kind of tough luck and really hard to avoid:
  # One user connects, and in the time between the start of the connection
  # and the appearance of pppd, captive_cleanup is called...
  def tes_fast_cleanup
    $lib_net.call_args( :user_connect, "1.1.1.1 foo" )
    assert_equal "foo", $lib_net.call( :users_connected )
    assert_equal "no", $lib_net.call( :isp_connected )

    $lib_net.call :captive_cleanup
    assert_equal "foo", $lib_net.call( :users_connected )
    assert_equal "yes", $lib_net.call( :isp_connected )    
  end
end