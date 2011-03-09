module Putkitin
  
  # This class represents an SSH gateway host.
  # It can be used to open Pipes through it.
  class Gateway
    
    attr_reader :hostname

    def initialize(sshhost)
      @hostname = sshhost
    end

    def pipe(host, port)
      return Putkitin::Pipe.new self, host, port
    end

  end
  
end
