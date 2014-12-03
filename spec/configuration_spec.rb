require File.expand_path('spec_helper', File.dirname(__FILE__))
require 'cxpbbg_rest'
require 'ostruct'

describe CxpbbgRest::Configuration, "default values without a cxpbbg.yml" do
  before(:each) do
    File.stub(:exist?).and_return(false) # simulate cxpbbg.yml not existing
    stub_const('Rails', double('Rails',:root => "#{Dir.pwd}/install/templates",
      "::VERSION::MAJOR" => 4,
      "::VERSION::MINOR"=>1))
    @config = CxpbbgRest::Configuration.new
  end
  
  it "should handle the 'hostname' property when not set" do
    expect(@config.hostname).to eql('localhost') 
  end
  
  it "should handle the 'path' property when not set" do
    expect(@config.path).to eql('/api/contents/feed')
  end
  
  it "should set the scheme to http" do
    expect(@config.scheme).to eql("http")
  end

  it "should default to port 3001 in development" do
    Rails.stub(:env => "development")
    @config = CxpbbgRest::Configuration.new
    expect(@config.port).to eql(3001)
  end
  
  it "should port generally default to 80" do
    Rails.stub(:env => "staging")
    @config = CxpbbgRest::Configuration.new
    expect(@config.port).to eql(80)
  end
  
  it "should set the read timeout to nil when not set" do
    expect(@config.read_timeout).to eql(nil)
  end

  it "should set the open timeout to nil when not set" do
    expect(@config.open_timeout).to eql(nil)
  end
  
  it "should set the username to 'name' not set" do
    expect(@config.username).to eql('name')
  end
  
  it "should set the password to 'name' not set" do
    expect(@config.password).to eql('secret')
  end
end
