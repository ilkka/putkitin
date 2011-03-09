require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'socket'

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

describe Putkitin::Pipe do
  include  FakeFS::SpecHelpers
  
  before :each do
    File.open("/etc/hosts", "w") do |f|
      f.write OriginalHosts
    end
  end

  it "opens ssh tunnels" do
    IO.should_receive(:popen) { |cmd|
      cmd.should =~ /ssh/
      cmd.should =~ /-L1234:example.com:1234/
    }
    gw = Putkitin::Gateway.new "gateway.example.com"
    pipe = gw.pipe "example.com", "1234"
    pipe.close
  end
  
  it "alters the hosts file" do
    gw = Putkitin::Gateway.new "gateway.example.com"
    pipe = gw.pipe "example.com", "1234"
    File.read("/etc/hosts").should == <<-EOS
192.168.0.1 #{Socket.gethostname}
127.0.0.1 localhost.localdomain localhost example.com
::1 #{Socket.gethostname} localhost6.localdomain6 localhost6 example.com
127.0.1.1 #{Socket.gethostname}

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
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

