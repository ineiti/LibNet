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
    # As lib_net will leave a child around, we have to fork it and
    # hope it's done in 1 second
    Process.detach( Process.fork { 
      %x[ #{@dir}/lib_net kill ]
      %x[ #{@dir}/lib_net ] 
    } )
    sleep 1
    %x[ #{@dir}/lib_net func captive_setup ]
    @env = call_print( :ENV )
    ddputs(3){"Env is at #{@env}"}
  end
	
  def call( func, *args )
    dputs(3){ "Called with #{func} - #{args.inspect}" }
    return %x[ #{@dir}/lib_net func #{func} #{args.join( ' ' )} ].chomp
  end

  def async( func, *args )
    ddputs(3){ "Async with #{func} - #{args.inspect}" }
    return %x[ #{@dir}/lib_net async #{func} #{args.join( ' ' )} ].chomp
  end
  
  def call_print( var )
    dputs(2){ "Printing #{var} through lib_net" }    
    return %x[ #{@dir}/lib_net print #{var} ].chomp
  end

  def print( var )
    dputs(4){ "Printing #{var}" }    
    IO.foreach(@env){|l|
      if l =~ /^#{var}=(.*)/
        return $1
      end
    }
    ""
  end

  #def call_args( func, argstr )
  #  ddputs(4){ "Going to call_args #{func} - #{argstr}" }
  #  return %x[ #{@dir}/lib_net func #{func} #{argstr} ].chomp
  #end
	
  def status
    "OK"
  end

  def path
    @dir
  end

  def isp_params
    Hash[ %w( ISP CONNECTION_TYPE HAS_PROMO HAS_CREDIT ALLOW_FREE ).collect{|v|
      [ v, print( v ) ]
    } ]
  end

  def get_var_file( var )
    if file = print( var )
      return IO.readlines( file )
    end
    return []
  end
end

if __FILE__ == $PROGRAM_NAME 
  DRb.start_service 'druby://:9000', LibNet.new
  dputs(0){ "Server running at #{DRb.uri}" }
 
  trap("INT") { DRb.stop_service }
  DRb.thread.join
end
