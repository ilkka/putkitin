module Putkitin

  # This class represents an open pipe through a gateway host.
  # One pipe for one target host / port combination.
  class Pipe

    # Create a new pipe.
    #
    # @param gw [Gateway] ssh gateway.
    # @param host [String] target hostname.
    # @param port [Int] port number.
    # @return [Pipe] open pipe.
    def initialize(gw, host, port)
      @io = IO.popen("ssh -L#{port}:#{host}:#{port} #{gw.hostname}")
    end

    # Close this pipe.
    #
    def close
    end

  end

end
