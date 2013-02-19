require 'spec_helper'

describe VectorEmbed do
  it "represents true/false/nil as 1/-1/0" do
    v = VectorEmbed.new
    v.line(true,  7 => true ).should == '1 7:1'
    v.line(false, 7 => false).should == '-1 7:-1'
    v.line(nil,   7 => nil  ).should == '0 7:0'
  end

  it "represents numbers as numbers" do
    v = VectorEmbed.new
    v.line(5,   1 => 9).should == '5 1:9'
    v.line(5.0, 1 => 9).should == '5.0 1:9'
    v.line(5.1, 1 => 9).should == '5.1 1:9'
  end

  it "allows number feature names (rare?)" do
    v = VectorEmbed.new
    v.line(5, 3 => 9).should == '5 3:9'
    v.line(5, 7 => 13).should == '5 7:13'
  end

  it "orders feature names" do
    v = VectorEmbed.new
    v.line(5, 88 => 1, 1 => 9, 55 => 3).should == '5 1:9 55:3 88:1'
  end

  it "allows arrays as feature values" do
    v = VectorEmbed.new
    v.line(5, 'foo' => [7,13,19]).should == "5 #{MurmurHash3::V32.str_hash('foo_1')}:13 #{MurmurHash3::V32.str_hash('foo_0')}:7 #{MurmurHash3::V32.str_hash('foo_2')}:19"
  end

  it "in number mode, treats nil or blank as 0" do
    v = VectorEmbed.new
    v.line(1, 1 => nil).should == '1 1:0'
    v.line(1, 1 => '').should == '1 1:0'
    v.line(1, 1 => '        ').should == '1 1:0'
  end

  it "in phrase mode, treats true/false/nil as strings" do
    v = VectorEmbed.new
    v.line(1, 1 => 'foo').should == "1 1:#{MurmurHash3::V32.str_hash('foo')}"
    v.line(1, 1 => true).should == "1 1:#{MurmurHash3::V32.str_hash('true')}"
    v.line(1, 1 => false).should == "1 1:#{MurmurHash3::V32.str_hash('false')}"
    v.line(1, 1 => nil).should == "1 1:#{MurmurHash3::V32.str_hash('')}"
  end

  it "in phrase mode, treats blanks literally" do
    v = VectorEmbed.new
    v.line(1, 1 => 'foo').should == "1 1:#{MurmurHash3::V32.str_hash('foo')}"
    v.line(1, 1 => '').should == "1 1:#{MurmurHash3::V32.str_hash('')}"
    v.line(1, 1 => '  ').should == "1 1:#{MurmurHash3::V32.str_hash('  ')}"
    v.line(1, 1 => '   ').should == "1 1:#{MurmurHash3::V32.str_hash('   ')}"
  end

  it "represents strings as hashes" do
    v = VectorEmbed.new
    v.line('foo', 1 => 9).should == "#{MurmurHash3::V32.str_hash('foo')} 1:9"
    v.line('bar', 1 => 9).should == "#{MurmurHash3::V32.str_hash('bar')} 1:9"
  end

  it "represents string values as hashes" do
    v = VectorEmbed.new
    v.line(1, a: :b                   ).should == "1 #{MurmurHash3::V32.str_hash('a')}:#{MurmurHash3::V32.str_hash('b')}"
    v.line(1, 'oh hello' => 'mr world').should == "1 #{MurmurHash3::V32.str_hash('oh hello')}:#{MurmurHash3::V32.str_hash('mr world')}"
  end

  it "treats numbers as strings if hashes have been used before" do
    v = VectorEmbed.new
    v.line('foo', 1 => 9).should == "#{MurmurHash3::V32.str_hash('foo')} 1:9"
    v.line(5, 1 => 9).should == "#{MurmurHash3::V32.str_hash('5')} 1:9"
    v = VectorEmbed.new
    v.line(1, a: :b).should == "1 #{MurmurHash3::V32.str_hash('a')}:#{MurmurHash3::V32.str_hash('b')}"
    v.line(1, a: 13).should == "1 #{MurmurHash3::V32.str_hash('a')}:#{MurmurHash3::V32.str_hash('13')}"
  end

  it "allows mixed hashed and number feature values" do
    v = VectorEmbed.new
    v.line(1, a: :b).should == "1 #{MurmurHash3::V32.str_hash('a')}:#{MurmurHash3::V32.str_hash('b')}"
    v.line(1, a: 13).should == "1 #{MurmurHash3::V32.str_hash('a')}:#{MurmurHash3::V32.str_hash('13')}"
    v.line(1, 1 => 9).should == "1 #{MurmurHash3::V32.str_hash('1')}:9" # 9 is not hashed, 1 is
  end

  it "doesn't allow true/false in number mode" do
    v = VectorEmbed.new
    v.line(1, 1 => 9).should == '1 1:9'
    lambda { v.line(true, 1 => 9) }.should raise_error(ArgumentError, /Can't embed.*number/)
  end

  it "doesn't allow strings in number mode" do
    v = VectorEmbed.new
    v.line(5, 1 => 9).should == '5 1:9'
    lambda { v.line('foo', 1 => 9) }.should raise_error(ArgumentError, /Can't embed.*number/)
  end

  it "embeds numbers as numbers" do
    v = VectorEmbed.new
    v.line(5, 1 => 9, 2 => 13.5).should == '5 1:9 2:13.5'
  end

  it "uses scientific notation for large numbers" do
    v = VectorEmbed.new
    v.line(5, 1 => 8.12e9).should == '5 1:8.120000e+09'
  end

  it "detects numbers in strings" do
    v = VectorEmbed.new
    v.line(5, 1 => '8.12e9').should == '5 1:8.120000e+09'
  end
end
