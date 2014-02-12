require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RestDebug" do
  let(:manager) do
    RestDebug::Manager.make(code)
  end

  after do
    manager.close
  end

  describe "basic" do
    let(:code) { "puts :abc" }
    it 'basic' do
      manager.client.read_all.split("\n").first.strip.should == "Connected."
    end
  end

  describe "breakpoint" do
    let(:code) do
      "puts 1
      puts 2
      puts 3"
    end

    before do
      manager.command "break file:2"
      20.times do
        manager.client.read
        sleep 0.05
      end
    end

    it 'smoke' do
      puts manager.client.read_all
      exp = "#{manager.server.tmp_filename}:6"
      manager.client.read_all.split("\n")[1].strip.should == exp

      manager.command :continue
      50.times { sleep 0.02 }
      str = manager.client.read
      str.split("\n")[1].strip.should == "Breakpoint 1 at #{manager.server.tmp_filename}:7"
    end
  end
end
