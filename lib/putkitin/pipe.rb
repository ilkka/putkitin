module Putkitin

  # This class represents an open pipe through a gateway host.
  # One pipe for one target host / port combination.
  class Pipe

    # Create a new pipe.
    #
    # @param gw [Gateway] ssh gateway.
    # @param host [String] target hostname.
    # @param port [int, Array] port number(s).
    # @return [Pipe] open pipe.
    def initialize(gw, host, ports)
      @host = host
      cmd = 
      @io = IO.popen(sshcmd(gw, host, ports))
      lines = []
      File.open('/etc/hosts').each do |line|
        line = case line
               when /^(127\.0\.0\.1|::1)\s.*/
                 line.chomp + " " + @host + "\n"
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
      lines = []
      @io.close
      File.open('/etc/hosts').each do |line|
        line = case line
               when /^(127\.0\.0\.1|::1)\s.*/
                 line.gsub " #{@host}", ''
               else
                 line
               end
        lines << line
      end
      File.open('/etc/hosts', 'w') do |f|
        lines.each { |l| f.write l }
      end
    end

    private

    def sshcmd(gateway, host, ports)
      "ssh -nN" + ([] << ports).flatten.reduce("") { |s,p|
        s + " -L#{p}:#{host}:#{p}"
      } + " #{gateway.hostname}"
    end

  end

end
