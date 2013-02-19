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
    v.line(5, 'foo' => [7,13,19]).should == "5 #{h('foo_1')}:13 #{h('foo_0')}:7 #{h('foo_2')}:19"
  end

  it "in number mode, treats nil as 0" do
    v = VectorEmbed.new
    v.line(1, 1 => nil).should == '1 1:0'
    v.line(1, 1 => 'null').should == '1 1:0'
  end

  it "in phrase mode, treats true/false/nil as strings" do
    v = VectorEmbed.new
    v.line(1, 1 => 'foo').should == "1 1:#{h('foo')}"
    v.line(1, 1 => true).should == "1 1:#{h('true')}"
    v.line(1, 1 => false).should == "1 1:#{h('false')}"
    v.line(1, 1 => nil).should == "1 1:#{h('')}"
  end

  it "collapses whitespace" do
    v = VectorEmbed.new
    v.line(1, 1 => 'foo').should == "1 1:#{h('foo')}"
    v.line(1, 1 => '').should == "1 1:#{h('')}"
    v.line(1, 1 => '  ').should == "1 1:#{h('')}"
    v.line(1, 1 => '   ').should == "1 1:#{h('')}"
  end

  it "represents strings as hashes" do
    v = VectorEmbed.new
    v.line('foo', 1 => 9).should == "#{h('foo')} 1:9"
    v.line('bar', 1 => 9).should == "#{h('bar')} 1:9"
  end

  it "represents string values as hashes" do
    v = VectorEmbed.new
    v.line(1, a: :b                   ).should == "1 #{h('a')}:#{h('b')}"
    v.line(1, 'oh hello' => 'mr world').should == "1 #{h('oh hello')}:#{h('mr world')}"
  end

  it "treats numbers as strings if hashes have been used before" do
    v = VectorEmbed.new
    v.line('foo', 1 => 9).should == "#{h('foo')} 1:9"
    v.line(5, 1 => 9).should == "#{h('5')} 1:9"
    v = VectorEmbed.new
    v.line(1, a: :b).should == "1 #{h('a')}:#{h('b')}"
    v.line(1, a: 13).should == "1 #{h('a')}:#{h('13')}"
  end

  it "allows mixed hashed and number feature values" do
    v = VectorEmbed.new
    v.line(1, a: :b).should == "1 #{h('a')}:#{h('b')}"
    v.line(1, a: 13).should == "1 #{h('a')}:#{h('13')}"
    v.line(1, 1 => 9).should == "1 #{h('1')}:9" # 9 is not hashed, 1 is
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
    v.line(5, 1 => 8.12e13).should == '5 1:8.1200000000e+13'
  end

  it "detects numbers in strings" do
    v = VectorEmbed.new
    v.line(5, 1 => '8.12e13').should == '5 1:8.1200000000e+13'
  end

  it "allows 2 byte n-grams" do
    v = VectorEmbed.new ngram_len: 2, ngram_delim: ''
    v.line(1, 1 => 'foo').should == "1 #{h('ngram_fo')}:1 #{h('ngram_oo')}:1"
    v.line(1, 1 => 'bar').should == "1 #{h('ngram_ar')}:1 #{h('ngram_ba')}:1"
    v.line(1, 1 => 'baz').should == "1 #{h('ngram_az')}:1 #{h('ngram_ba')}:1"
    v.line(1, 1 => 'foobar').should == "1 #{h('ngram_ar')}:1 #{h('ngram_fo')}:1 #{h('ngram_oo')}:1 #{h('ngram_ob')}:1 #{h('ngram_ba')}:1"
    v.line(1, 1 => 'foo bar').should == "1 #{h('ngram__b')}:1 #{h('ngram_ar')}:1 #{h('ngram_fo')}:1 #{h('ngram_oo')}:1 #{h('ngram_o_')}:1 #{h('ngram_ba')}:1"
  end

  it "allows word-grams" do
    v = VectorEmbed.new ngram_len: 1, ngram_delim: /\s+/
    v.line(1, 1 => 'foo').should == "1 #{h('ngram_foo')}:1"
    v.line(1, 1 => 'foobar').should == "1 #{h('ngram_foobar')}:1"
    v.line(1, 1 => 'foo bar').should == "1 #{h('ngram_bar')}:1 #{h('ngram_foo')}:1"
  end

  it "allows 2 byte n-grams with stop words" do
    v = VectorEmbed.new ngram_len: 2, ngram_delim: '', stop_words: %w{the and or}
    v.line(1, 1 => 'foo or').should == "1 #{h('ngram_fo')}:1 #{h('ngram_oo')}:1"
    v.line(1, 1 => 'the bar').should == "1 #{h('ngram_ar')}:1 #{h('ngram_ba')}:1"
    v.line(1, 1 => 'and baz').should == "1 #{h('ngram_az')}:1 #{h('ngram_ba')}:1"
    v.line(1, 1 => 'foobar or the and').should == "1 #{h('ngram_ar')}:1 #{h('ngram_fo')}:1 #{h('ngram_oo')}:1 #{h('ngram_ob')}:1 #{h('ngram_ba')}:1"
    v.line(1, 1 => 'foo or and the bar').should == "1 #{h('ngram__b')}:1 #{h('ngram_ar')}:1 #{h('ngram_fo')}:1 #{h('ngram_oo')}:1 #{h('ngram_o_')}:1 #{h('ngram_ba')}:1"
  end

  it "allows word-grams with stop words" do
    v = VectorEmbed.new ngram_len: 1, ngram_delim: /\s+/, stop_words: %w{the and or}
    v.line(1, 1 => 'foo or').should == "1 #{h('ngram_foo')}:1"
    v.line(1, 1 => 'foo the bar').should == "1 #{h('ngram_bar')}:1 #{h('ngram_foo')}:1"
    v.line(1, 1 => 'foo bar and').should == "1 #{h('ngram_bar')}:1 #{h('ngram_foo')}:1"
  end

  private

  def h(v)
    num = MurmurHash3::V32.str_hash v
  end
end
