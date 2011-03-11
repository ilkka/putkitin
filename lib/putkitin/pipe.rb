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
      lines = []
      File.open('/etc/hosts').each do |line|
        line = case line
               when /^(127\.0\.0\.1|::1)\s.*/
                 line.chomp + " " + host + "\n"
               else
                 line
               end
        lines << line
      end
      File.open('/etc/hosts', 'w') do |f|
        lines.each { |l| f.write l }
      end
    end

    # Close this pipe.
    #
    def close
    end

  end

end
