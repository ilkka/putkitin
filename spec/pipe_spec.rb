require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

OriginalHosts = <<EOS
192.168.0.1 #{Socket.gethostname}
127.0.0.1 localhost.localdomain localhost
::1 #{Socket.gethostname} localhost6.localdomain6 localhost6
127.0.1.1 #{Socket.gethostname}

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOS

# this netstat-like stuff pilfered from
# http://snippets.dzone.com/posts/show/12653

# This regex pattern groks lines on /proc/net/tcp
TCP_STAT_PAT = /^\s*\d+:\s+(.{8}):(.{4})\s+(.{8}):(.{4})\s+(.{2})/

# Check for a connection on a given port
# that is in the "listening" state.
#
# @param port [int] port number.
# @return [Boolean] true if there's a listening connection.
def listening_on_port?(port)
  File.open('/proc/net/tcp').map { |line|
    line.strip.match(TCP_STAT_PAT) { |match|
      [match[2].to_i(16), match[5]]
    }
  }.any? { |c|
    c && c[1] == '0A' && c[0] == port
  }
end

describe Putkitin::Pipe do
  include  FakeFS::SpecHelpers
  
  before :each do
    File.open("/etc/hosts", "w") do |f|
      f.write OriginalHosts
    end
    # fakefs messes with tempfile so re-make the temp dir
    FakeFS::FileUtils.mkdir_p Dir.tmpdir
  end

  it "opens ssh tunnels" do
    IO.should_receive(:popen) { |cmd|
      cmd.should =~ /ssh/
      cmd.should =~ /-L1234:example.com:1234/
      cmd.should =~ /gateway.example.com/
      IO.pipe[0]
    }
    gw = Putkitin::Gateway.new "gateway.example.com"
    pipe = gw.pipe "example.com", "1234"
    pipe.close
  end
  
  it "alters the hosts file" do
    IO.should_receive(:popen) { |cmd|
      IO.pipe[0]
    }
    gw = Putkitin::Gateway.new "gateway.example.com"
    pipe = gw.pipe "example.com", "1234"
    File.read("/etc/hosts").should == <<-EOS
192.168.0.1 #{Socket.gethostname}
127.0.0.1 localhost.localdomain localhost example.com
::1 #{Socket.gethostname} localhost6.localdomain6 localhost6 example.com
127.0.1.1 #{Socket.gethostname}

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback example.com
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOS
    pipe.close
    File.read("/etc/hosts").should == OriginalHosts
  end
end

