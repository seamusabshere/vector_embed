require 'spec_helper'

describe VectorEmbed do
  it "supports true/false/nil labels" do
    v = VectorEmbed.new
    v.line(true,  a: 9).should == '1 1:9'
    v.line(false, a: 9).should == '-1 1:9'
    v.line(nil,   a: 9).should == '0 1:9'
  end

  it "supports numeric labels" do
    v = VectorEmbed.new
    v.line(5, a: 9).should == '5 1:9'
    v.line(5.0, a: 9).should == '5.0 1:9'
    v.line(5.1, a: 9).should == '5.1 1:9'
  end

  it "supports string labels" do
    v = VectorEmbed.new
    v.line('foo', a: 9).should == '1 1:9'
    v.line('foo', a: 9).should == '1 1:9'
    v.line('bar', a: 9).should == '2 1:9'
    v.line(5, a: 9).should == '3 1:9'
    v.line(5, a: 9).should == '3 1:9'
    v.line(8, a: 9).should == '4 1:9'
  end

  it "supports continuous feature names (rare?)" do
    v = VectorEmbed.new
    v.line(5, 3 => 9).should == '5 3:9'
    v.line(5, 7 => 13).should == '5 7:13'
  end

  it "doesn't allow string labels after starting with numeric labels" do
    v = VectorEmbed.new
    v.line(5, a: 9).should == '5 1:9'
    lambda { v.line('foo', a: 9) }.should raise_error(ArgumentError, /Can't embed.*string.*continuous/)
  end

  it "embeds numbers as numbers" do
    v = VectorEmbed.new
    v.line(5, a: 9, b: 13.5).should == '5 1:9 2:13.5'
  end

  it "uses scientific notation for large numbers" do
    v = VectorEmbed.new
    v.line(5, a: 8.12e9).should == '5 1:8.120000e+09'
    v.line(5, a: '8.12e9').should == '5 1:8.120000e+09'
  end
end
