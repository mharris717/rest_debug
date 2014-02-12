require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RestDebug" do
  it "smoke" do
    2.should == 2
  end

  let(:manager) do
    RestDebug::Manager.make("puts :abc")
  end

  after do
    manager.close
  end

  it 'runs' do
    manager.client.read_all.split("\n").first.strip.should == "Connected."
  end
end
