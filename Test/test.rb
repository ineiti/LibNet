#!/usr/bin/ruby -I../../QooxView -I../../AfriCompta -I../../LibNet -wKU
require 'test/unit'

DEBUG_LVL=2

#require 'QooxView'
require 'LibNet'

$lib_net = LibNet.new

tests = %w( users )
#tests = %w( internet )
tests.each{|t|
  require "ln_#{t}"
}
