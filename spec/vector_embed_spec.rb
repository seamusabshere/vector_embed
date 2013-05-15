require 'spec_helper'

describe VectorEmbed do
  describe 'in labels' do
    it "stores true/false as 1/0" do
      v = VectorEmbed.new
      v.line(true).should == '1'
      v.line(false).should == '0'
      v.line('true').should == '1'
      v.line('false').should == '0'
    end

    it "stores numbers as numbers" do
      v = VectorEmbed.new
      v.line(5.4).should == '5.4'
      v.line(-3.9).should == '-3.9'
    end

    it "doesn't allow strings" do
      v = VectorEmbed.new
      lambda { v.line('foo') }.should raise_error(/string.*label/i)
    end

    it "doesn't allow mixing" do
      v = VectorEmbed.new
      v.line(5.4)
      lambda { v.line(true) }.should raise_error(/Can't embed.*number/)
      v = VectorEmbed.new
      v.line(true)
      lambda { v.line(5.4) }.should raise_error(/Can't embed.*boolean/)
    end
  end

  describe 'using a dictionary' do
    it "starts at feature label 1" do
      v = VectorEmbed.new dict: {}
      v.line(1, 'foo' => 5).should == "1 1:5"
      v.line(1, 'bar' => 3).should == "1 2:3"
      v.line(1, 'foo' => 3, 'bar' => 5).should == "1 1:3 2:5"
    end

    it "does not modify the original dict" do
      orig = {}
      v = VectorEmbed.new dict: orig
      v.line(1, 'foo' => 5)
      orig.should == {}
    end

    it "provides the latest dict on demand" do
      require 'digest/md5'
      v = VectorEmbed.new dict: {}
      v.line(1, 'foo' => 5)
      v.dict.should == { Digest::MD5.digest('foo') => 1 }
    end
  end

  # aka dimension indexes
  describe 'in feature keys' do
    it "stores values as their string equivalents" do
      v = VectorEmbed.new
      v.line(1, 1 => 9).should == "1 #{l_h('1')}:9"
      v.line(1, 5.4 => 9).should == "1 #{l_h('5.4')}:9"
      v.line(1, '5.4' => 9).should == "1 #{l_h('5.4')}:9"
      v.line(1, '5.4 ' => 9).should == "1 #{l_h('5.4 ')}:9"
      v.line(1, 'foo' => 9).should == "1 #{l_h('foo')}:9"
      v.line(1, 'foo bar' => 9).should == "1 #{l_h('foo bar')}:9"
      v.line(1, true => 9).should == "1 #{l_h('true')}:9"
      v.line(1, 'true' => 9).should == "1 #{l_h('true')}:9"
      v.line(1, false => 9).should == "1 #{l_h('false')}:9"
      v.line(1, 'false' => 9).should == "1 #{l_h('false')}:9"
    end

    it "treats nil as a blank string" do
      v = VectorEmbed.new
      v.line(1, nil => 9).should == "1 #{l_h('')}:9"
    end

    it "leaves whitespace alone" do
      v = VectorEmbed.new
      v.line(1, '' => 9).should == "1 #{l_h('')}:9"
      v.line(1, ' ' => 9).should == "1 #{l_h(' ')}:9"
      v.line(1, '  ' => 9).should == "1 #{l_h('  ')}:9"
      v.line(1, ' foo ' => 9).should == "1 #{l_h(' foo ')}:9"
      v.line(1, '5.4 ' => 9).should == "1 #{l_h('5.4 ')}:9"
    end

    it "orders feature names" do
      v = VectorEmbed.new
      v.line(1, 1 => 3, 2 => 7).should == "1 #{l_h('2')}:7 #{l_h('1')}:3"
    end

    it "allows mixed string and number feature values" do
      v = VectorEmbed.new
      v.line(1, a: :b).should == "1 #{l_h("a\x00b")}:1"
      v.line(1, a: 13).should == "1 #{l_h("a\x0013")}:1"
      v.line(1, 1 => 9).should == "1 #{l_h('1')}:9" # 9 is not hashed, 1 is
    end
  end

  describe 'feature values' do
    describe 'in boolean attributes' do
      it "stores true/false/nil as (1,0,0)/(0,1,0)/(0,0,1)" do
        v = VectorEmbed.new
        v.line(1, 1 => true).should == "1 #{l_h("1\x00true")}:1"
        v.line(1, 1 => 'true').should == "1 #{l_h("1\x00true")}:1"
        v.line(1, 1 => 'TRUE').should == "1 #{l_h("1\x00true")}:1"
        v.line(1, 1 => 't').should == "1 #{l_h("1\x00true")}:1"
        v.line(1, 1 => 'T').should == "1 #{l_h("1\x00true")}:1"
        v.line(1, 1 => false).should == "1 #{l_h("1\x00false")}:1"
        v.line(1, 1 => 'false').should == "1 #{l_h("1\x00false")}:1"
        v.line(1, 1 => 'FALSE').should == "1 #{l_h("1\x00false")}:1"
        v.line(1, 1 => 'f').should == "1 #{l_h("1\x00false")}:1"
        v.line(1, 1 => 'F').should == "1 #{l_h("1\x00false")}:1"
        v.line(1, 1 => nil).should == "1 #{l_h("1\x00null")}:1"
        v.line(1, 1 => 'null').should == "1 #{l_h("1\x00null")}:1"
        v.line(1, 1 => 'NULL').should == "1 #{l_h("1\x00null")}:1"
        v.line(1, 1 => '\N').should == "1 #{l_h("1\x00null")}:1"
      end
    end

    it "stores numbers as numbers" do
      v = VectorEmbed.new
      v.line(1, 1 => 9).should == "1 #{l_h('1')}:9"
      v.line(1, 1 => '9').should == "1 #{l_h('1')}:9"
      v.line(1, 1 => 5.4).should == "1 #{l_h('1')}:5.4"
      v.line(1, 1 => '5.4').should == "1 #{l_h('1')}:5.4"
      v.line(1, 1 => 9e9).should == "1 #{l_h('1')}:9000000000"
      v.line(1, 1 => '9e9').should == "1 #{l_h('1')}:9000000000"
    end

    it "does not output 0 in number attributes" do
      v = VectorEmbed.new
      v.line(3, 1 => 1)
      v.line(3, 1 => 0).should == "3"
      v.line(3, 1 => '0').should == "3"
    end

    it "treats nil like zero in number attributes" do
      v = VectorEmbed.new
      v.line(1, 1 => 1) # establish it's a number
      v.line(1, 1 => nil).should == v.line(1, 1 => 0)
    end

    it "assumes nil value means a number field" do
      v = VectorEmbed.new
      v.line(3, 1 => nil) # don't establish it's a number
      v.line(3, 1 => nil).should == v.line(3, 1 => 0)
      v.line(3, 1 => 'null').should == v.line(3, 1 => 0)
      v.line(3, 1 => 'NULL').should == v.line(3, 1 => 0)
      v.line(3, 1 => '\N').should == v.line(3, 1 => 0)
    end

    it "stores strings as m-category attributes" do
      v = VectorEmbed.new
      v.line(1, 1 => 'sfh').should == "1 #{l_h("1\x00sfh")}:1"
      v.line(1, 1 => 'mfh').should == "1 #{l_h("1\x00mfh")}:1"
      v.line(1, 1 => 'foo bar').should == "1 #{l_h("1\x00foo bar")}:1"
      v.line(1, 1 => 'foo  bar ').should == "1 #{l_h("1\x00foo bar")}:1"
      v.line(1, 1 => ' foo   bar  ').should == "1 #{l_h("1\x00foo bar")}:1"
    end

    it "in string mode, treats true/false/nil as strings" do
      v = VectorEmbed.new
      v.line(1, 1 => 'foo').should == "1 #{l_h("1\x00foo")}:1"
      v.line(1, 1 => true).should == "1 #{l_h("1\x00true")}:1"
      v.line(1, 1 => false).should == "1 #{l_h("1\x00false")}:1"
      v.line(1, 1 => nil).should == "1 #{l_h("1\x00")}:1"
    end

    it "in string mode, treats numbers as strings" do
      v = VectorEmbed.new
      v.line(1, 1 => 'foo').should == "1 #{l_h("1\x00foo")}:1"
      v.line(1, 1 => 1).should == "1 #{l_h("1\x001")}:1"
      v.line(1, 1 => 5.4).should == "1 #{l_h("1\x005.4")}:1"
      v.line(1, 1 => 9e9).should == "1 #{l_h("1\x00" + 9e9.to_s)}:1"
    end

    it "flattens and stores arrays" do
      v = VectorEmbed.new
      v.line(1, 'foo' => [7,13,19]).should == sortme("1 #{l_h("foo\x001")}:13 #{l_h("foo\x000")}:7 #{l_h("foo\x002")}:19")
      v.line(1, 'bar' => ['a','b','c']).should == sortme("1 #{l_h("bar\x001\x00b")}:1 #{l_h("bar\x000\x00a")}:1 #{l_h("bar\x002\x00c")}:1")
    end

    it "stores arrays with proper indices even if some values are zero" do
      v = VectorEmbed.new
      v.line(1, 'foo' => [0,99]).should == sortme("1 #{l_h("foo\x001")}:99")
      v.line(1, 'foo' => [45,0]).should == sortme("1 #{l_h("foo\x000")}:45")
      v.line(1, 'foo' => [45,99]).should == sortme("1 #{l_h("foo\x000")}:45 #{l_h("foo\x001")}:99")
      v = VectorEmbed.new
      v.line(1, 'foo' => [45,0,99]).should == sortme("1 #{l_h("foo\x000")}:45 #{l_h("foo\x002")}:99")
      v.line(1, 'foo' => [45,0]).should == sortme("1 #{l_h("foo\x000")}:45")
      v.line(1, 'foo' => [45,33,99]).should == sortme("1 #{l_h("foo\x000")}:45 #{l_h("foo\x001")}:33 #{l_h("foo\x002")}:99")
    end

    it "in number mode, treats null as 0" do
      v = VectorEmbed.new
      v.line(1, 1 => 9).should == "1 #{l_h('1')}:9"
      v.line(1, 1 => nil).should == v.line(1, 1 => 0)
      v.line(1, 1 => 'null').should == v.line(1, 1 => 0)
      v.line(1, 1 => 'NULL').should == v.line(1, 1 => 0)
      v.line(1, 1 => '\N').should == v.line(1, 1 => 0)
    end

    it "doesn't allow embedding boolean in number mode or vice-versa" do
      v = VectorEmbed.new
      v.line(1, 1 => true)
      v.line(1, 2 => 5.4) # that's fine, different dimension
      lambda { v.line(1, 1 => 5.4) }.should raise_error(ArgumentError)
      v = VectorEmbed.new
      v.line(1, 1 => 5.4)
      v.line(1, 2 => true) # that's fine, diff dim
      lambda { v.line(1, 1 => true) }.should raise_error(ArgumentError)
    end

    it "doesn't allow embedding string in number mode" do
      v = VectorEmbed.new
      v.line(1, 1 => 9)
      v.line(1, 2 => 'foo') # that's fine, different dimension
      lambda { v.line(1, 1 => 'foo') }.should raise_error(ArgumentError)
    end

    it "uses scientific notation for large numbers" do
      v = VectorEmbed.new
      v.line(5, 1 => 8.12e27).should == "5 #{l_h('1')}:8.12e+27"
    end

    it "detects numbers in strings" do
      v = VectorEmbed.new
      v.line(5, 1 => '8.12e13').should == "5 #{l_h('1')}:81200000000000"
    end

    it "allows 2 byte n-grams" do
      v = VectorEmbed.new ngram_len: 2, ngram_delim: ''
      v.line(1, 1 => 'foo').should == sortme("1 #{l_h("1\x00ngram\x00fo")}:1 #{l_h("1\x00ngram\x00oo")}:1")
      v.line(1, 1 => 'bar').should == sortme("1 #{l_h("1\x00ngram\x00ar")}:1 #{l_h("1\x00ngram\x00ba")}:1")
      v.line(1, 1 => 'baz').should == sortme("1 #{l_h("1\x00ngram\x00az")}:1 #{l_h("1\x00ngram\x00ba")}:1")
      v.line(1, 1 => 'foobar').should == sortme("1 #{l_h("1\x00ngram\x00ar")}:1 #{l_h("1\x00ngram\x00fo")}:1 #{l_h("1\x00ngram\x00oo")}:1 #{l_h("1\x00ngram\x00ob")}:1 #{l_h("1\x00ngram\x00ba")}:1")
      v.line(1, 1 => 'foo bar').should == sortme("1 #{l_h("1\x00ngram\x00fo")}:1 #{l_h("1\x00ngram\x00oo")}:1 #{l_h("1\x00ngram\x00o ")}:1 #{l_h("1\x00ngram\x00 b")}:1 #{l_h("1\x00ngram\x00ba")}:1 #{l_h("1\x00ngram\x00ar")}:1")
    end

    it "allows word-grams" do
      v = VectorEmbed.new ngram_len: 1, ngram_delim: /\s+/
      v.line(1, 1 => 'foo').should == sortme("1 #{l_h("1\x00ngram\x00foo")}:1")
      v.line(1, 1 => 'foobar').should == sortme("1 #{l_h("1\x00ngram\x00foobar")}:1")
      v.line(1, 1 => 'foo bar').should == sortme("1 #{l_h("1\x00ngram\x00bar")}:1 #{l_h("1\x00ngram\x00foo")}:1")
    end

    it "allows 2 byte n-grams with stop words" do
      v = VectorEmbed.new ngram_len: 2, ngram_delim: '', stop_words: %w{the and or}
      v.line(1, 1 => 'foo or').should == sortme("1 #{l_h("1\x00ngram\x00fo")}:1 #{l_h("1\x00ngram\x00oo")}:1")
      v.line(1, 1 => 'the bar').should == sortme("1 #{l_h("1\x00ngram\x00ar")}:1 #{l_h("1\x00ngram\x00ba")}:1")
      v.line(1, 1 => 'and baz').should == sortme("1 #{l_h("1\x00ngram\x00az")}:1 #{l_h("1\x00ngram\x00ba")}:1")
      v.line(1, 1 => 'foobar or the and').should == sortme("1 #{l_h("1\x00ngram\x00ar")}:1 #{l_h("1\x00ngram\x00fo")}:1 #{l_h("1\x00ngram\x00oo")}:1 #{l_h("1\x00ngram\x00ob")}:1 #{l_h("1\x00ngram\x00ba")}:1")
      v.line(1, 1 => 'foo or and the bar').should == sortme("1 #{l_h("1\x00ngram\x00 b")}:1 #{l_h("1\x00ngram\x00ar")}:1 #{l_h("1\x00ngram\x00fo")}:1 #{l_h("1\x00ngram\x00oo")}:1 #{l_h("1\x00ngram\x00o ")}:1 #{l_h("1\x00ngram\x00ba")}:1")
    end

    it "allows word-grams with stop words" do
      v = VectorEmbed.new ngram_len: 1, ngram_delim: /\s+/, stop_words: %w{the and or}
      v.line(1, 1 => 'foo or').should == "1 #{l_h("1\x00ngram\x00foo")}:1"
      v.line(1, 1 => 'foo the bar').should == "1 #{l_h("1\x00ngram\x00bar")}:1 #{l_h("1\x00ngram\x00foo")}:1"
      v.line(1, 1 => 'foo bar and').should == "1 #{l_h("1\x00ngram\x00bar")}:1 #{l_h("1\x00ngram\x00foo")}:1"
    end

    it "doesn't do anything weird when you have multiple features" do
      v = VectorEmbed.new
      v.line(1, 1 => 'foo', 2 => 'bar', 'baz' => 'zoo').should == sortme("1 #{l_h("1\x00foo")}:1 #{l_h("2\x00bar")}:1 #{l_h("baz\x00zoo")}:1")
    end

  end

  private

  def h(v)
    MurmurHash3::V32.str_hash v
  end

  # for labels
  def l_h(v)
    h(v).to_s[0..6].to_i
  end

  def sortme(line)
    parts = line.split(' ')
    label = parts.shift
    features = parts.map { |p| p.split(':') }.sort_by { |k, v| k.to_i }.map { |k, v| [k, v].join(':') }
    ([label] + features).join(' ')
  end
end
