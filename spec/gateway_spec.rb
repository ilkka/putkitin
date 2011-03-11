require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Putkitin::Gateway do
  include FakeFS::SpecHelpers

  before :each do
    @gw = Putkitin::Gateway.new 'example.com'
    FakeFS::FileUtils.mkdir_p Dir.tmpdir
    FakeFS::FileUtils.mkdir_p '/etc'
    File.open('/etc/hosts', 'w') do |f|
      f.write '127.0.0.1 localhost'
    end
  end
  
  it "takes ssh host as argument" do
    @gw.should be_a Putkitin::Gateway
  end

  it "returns a Pipe object" do
    pipe = @gw.pipe 'example.com', '1234'
    pipe.should be_a Putkitin::Pipe
  end

end

