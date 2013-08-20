#!/usr/bin/ruby -wKU
# This is the LibNet-wrapper for the bash-scripts that wrap the
# gateway-functionality of the internet-router.
# The bash-scripts are thought to be used in a wireless-router, too.

require 'drb'

SIMUL=true

if not respond_to? :dputs
  DEBUG_LVL=3
  
  def dputs(a,&b)
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
    if not SIMUL
      Process.detach( Process.fork { 
          dputs(3){"killing"}
          %x[ #{@dir}/lib_net kill ]
          dputs(3){"init"}
          %x[ #{@dir}/lib_net ping ]
          dputs(3){"finished"}
        } )
      sleep 1
      dputs(3){"setting up"}
      %x[ #{@dir}/lib_net func captive_setup ]
      @env = call_print( :ENV )
      dputs(3){"Env is at #{@env}"}
    else
      dputs(1){"Simulation only"}
    end
  end
	
  def call( func, *args )
    dputs(3){ "Called with #{func} - #{args.inspect}" }
    SIMUL and return ""
    return %x[ #{@dir}/lib_net func #{func} #{args.join( ' ' )} ].chomp
  end

  def async( func, *args )
    dputs(3){ "Async with #{func} - #{args.inspect}" }
    SIMUL and return ""
    return %x[ #{@dir}/lib_net async #{func} #{args.join( ' ' )} ].chomp
  end
  
  def call_print( var )
    dputs(2){ "Printing #{var} through lib_net" }    
    SIMUL and return ""
    return %x[ #{@dir}/lib_net print #{var} ].chomp
  end

  def print( var )
    dputs(4){ "Printing #{var}" }    
    SIMUL and return ""
    IO.foreach(@env){|l|
      if l =~ /^#{var}=(.*)/
        return $1
      end
    }
    ""
  end

  #def call_args( func, argstr )
  #  dputs(4){ "Going to call_args #{func} - #{argstr}" }
  #  return %x[ #{@dir}/lib_net func #{func} #{argstr} ].chomp
  #end
	
  def status
    "OK"
  end

  def path
    @dir
  end

  def isp_params
    SIMUL and return {}
    Hash[ %w( ISP CONNECTION_TYPE HAS_PROMO HAS_CREDIT ALLOW_FREE ).collect{|v|
        [ v.downcase, print( v ) ]
      } ]
  end

  def get_var_file( var )
    SIMUL and return []
    if ( file = print( var ) ) and File.exists?( file )
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
