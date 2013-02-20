# VectorEmbed

Vector embedding of strings, booleans, numerics, and arrays into [LIBSVM](http://www.csie.ntu.edu.tw/~cjlin/libsvm/) / [LIBLINEAR](http://www.csie.ntu.edu.tw/~cjlin/liblinear/) format.

Inspired by [Sally](http://www.mlsec.org/sally/), except `VectorEmbed` is meant to handle categorical and continuous data at the same time.

## Usage

Create a `VectorEmbed` instance, which auto-detects and then remembers what kind of data goes into each feature:

    >> require 'vector_embed'
    => true
    >> v = VectorEmbed.new
    => #<VectorEmbed:0x007fd605815208 [...]>

Output a line with a label and arbitrary features:

    >> label = 1
    => 1
    >> features = { color: 'red', year: 1995, weight: 5.4e9 }
    => {:color=>"red", :year=>1995, :weight=>5400000000.0}
    >> v.line(label, features)
    => "1 1997960:1 5556418:5400000000.0 8227451:1995"

Output another line:

    >> label = 0
    => 0
    >> features = { color: 'blue', year: 1821, weight: 3.3 }
    => {:color=>"blue", :year=>1821, :weight=>3.3}
    >> v.line(label, features)
    => "0 1089740:1 5556418:3.3 8227451:1821"

Note that `color: 'red'` and `color: 'blue'` are being translated into categories:

    1997960:1 # murmur3("color\x00red"):1
    1089740:1 # murmur3("color\x00blue"):1

A similar thing happens with `true`/`false`:

    >> v.line(1, yes: true, no: false)
    => "1 1559987:1 3324244:1"

i.e.

    1559987:1 # murmur3("yes\x00true"):1
    3324244:1 # murmur3("no\x00false"):1

## N-grams

Currently uses same parameter names as [Sally](http://www.mlsec.org/sally/manual.html).

### Word ngrams

    >> v = VectorEmbed.new ngram_len: 1, ngram_delim: /\s+/, stop_words: %w{the and or}
    => #<VectorEmbed:0x007fd6033b77f8 [...]>
    >> v.line(1, notes: 'the quick brown fox')
    => "1 1512788:1 3426202:1 5079692:1"

You get the idea: ("the" has been filtered out by stop words)

    1512788:1 # murmur3("notes\x00quick"):1
    3426202:1 # murmur3("notes\x00brown"):1
    5079692:1 # murmur3("notes\x00fox"):1

## Byte n-grams

    >> v = VectorEmbed.new ngram_len: 2, ngram_delim: ''
    => #<VectorEmbed:0x007fd60337ea20 [...]>
    >> v.line(1, notes: 'foobar')
    => "1 2148745:1 2878919:1 3600333:1 3621715:1 5885921:1"

So therefore:

    2148745:1 # murmur3("notes\x00fo"):1
    2878919:1 # murmur3("notes\x00oo"):1
    3600333:1 # murmur3("notes\x00ob"):1
    3621715:1 # murmur3("notes\x00ba"):1
    5885921:1 # murmur3("notes\x00ar"):1

## Debugging

`VectorEmbed` tries to do the right thing, but if it's not, try turning on debugging:

    >> v = VectorEmbed.new
    => #<VectorEmbed:0x007fd6034020a0 [...]>
    >> v.logger.level = Logger::DEBUG
    => 0
    >> v.line(1, '3' => 7, foo: 'bar', truthy: false, nullity: nil)
    D, [2013-02-20T16:55:00.139299 #21595] DEBUG -- : Interpreting "3" as Number given first value 7
    D, [2013-02-20T16:55:00.139561 #21595] DEBUG -- : Interpreting :foo as Phrase given first value "bar"
    D, [2013-02-20T16:55:00.139671 #21595] DEBUG -- : Interpreting :truthy as Boolean given first value false
    D, [2013-02-20T16:55:00.139755 #21595] DEBUG -- : Interpreting :nullity as Boolean given first value nil
    D, [2013-02-20T16:55:00.139872 #21595] DEBUG -- : Interpreting "label" as Number given first value 1
    => "1 2647413:7 4091306:1 7123386:1 9259635:1"

One thing it doesn't like: (assuming you have already performed the lines above)

    >> v.line(1, '3' => 'bar')
    ArgumentError: Can't embed "bar" in number feature "3".

It's saying that, given you first passed it `7`, it thought `"3"` was a feature that held numbers.

## Gotchas

* Following Sally, it only uses the first 22 bits of the murmur hash for feature indices... more and LIBSVM seems to choke.
* Stop words are currently filtered out of feature indices... probably shouldn't be.

## Copyright

Copyright 2013 Seamus Abshere
