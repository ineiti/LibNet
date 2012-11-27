#!/usr/bin/ruby -wKU
# This is the LibNet-wrapper for the bash-scripts that wrap the
# gateway-functionality of the internet-router.
# The bash-scripts are thought to be used in a wireless-router, too.

require 'drb'

if not respond_to? :dputs
  DEBUG_LVL=3
  
  def ddputs(a,&b)
    puts yield b
  end
  
  def dputs(a,&b)
    if a <= DEBUG_LVL
      puts yield b
    end
  end
end

class LibNet
  def initialize
    @dir = File.dirname( __FILE__ )
    %x[ #{@dir}/lib_net func captive_setup ]
  end
	
  def call( func, reply = nil )
    dputs(3){ "Called with #{func} - #{reply}" }
    s = ""
    if reply
      s = "print #{reply}"
    end
    if func
      s += " func #{func}"
    end
    dputs(4){ "Going to call #{s}" }
    return %x[ #{@dir}/lib_net #{s} ].chomp
  end

  def call_args( func, argstr )
    dputs(4){ "Going to call_args #{func} - #{argstr}" }
    return %x[ #{@dir}/lib_net func #{func} #{argstr} ].chomp
  end
	
  def status
    "OK"
  end
end

if __FILE__ == $PROGRAM_NAME 
  DRb.start_service 'druby://:9000', LibNet.new
  dputs(0){ "Server running at #{DRb.uri}" }
 
  trap("INT") { DRb.stop_service }
  DRb.thread.join
end
