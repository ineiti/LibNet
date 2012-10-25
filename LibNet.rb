# This is the LibNet-wrapper for the bash-scripts that wrap the
# gateway-functionality of the internet-router.
# The bash-scripts are thought to be used in a wireless-router, too.

require 'drb'

class LibNet
  def initialize
    %x[ ./lib_net captive_setup ]
  end
	
	def call( func, reply = nil )
		if reply
		  return %x[ ./lib_net print #{reply} func #{func}]
		else
		  return %x[ ./lib_net func #{func}]
		end
	end
end

DRb.start_service 'druby://:9000', LibNet.new
puts "Server running at #{DRb.uri}"
 
trap("INT") { DRb.stop_service }
DRb.thread.join
