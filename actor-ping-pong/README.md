# Actor Ping Pong

The "hello world" program for actor-based concurrency is a game of Ping Pong
between two actors. Pretty much every language that has access to actors has at
least one Ping Pong example/tutorial on the Web. A few such examples include:

* [Scala Actors: A Short Tutorial](http://www.scala-lang.org/old/node/242)
* [A 'Ping Pong' Scala Akka actors example](http://alvinalexander.com/scala/scala-akka-actors-ping-pong-simple-example)
* [Introduction to Erlang : Message Passing](http://trigonakis.com/blog/2011/05/26/introduction-to-erlang-message-passing/)
* [Actors in F#](http://blogs.msdn.com/b/concurrently_speaking/archive/2009/05/12/actors-in-f.aspx)
* [Parallel and Concurrent Programming in Haskell](http://chimera.labs.oreilly.com/books/1230000000929/ch14.html)
* [Distributed Actors in Java and Clojure](http://blog.paralleluniverse.co/2013/07/26/distributed-actors-in-java-and-clojure/)
* [Concurrent and Distributed Programming with Erlang and Elixir](http://www.huffingtonpost.com/jose-valim/concurrent-and-distribute_b_4350533.html)
* [An Introduction to Programming in Go | Concurrency](http://www.golang-book.com/10)

There are probably others, but you get the idea...

## What It Does

This program defines two [actors](https://github.com/jdantonio/concurrent-ruby/wiki/Actor)
classes called `Ping` and `Pong`. `Ping` listens for incoming messages and
responds with `:ping`. `Pong` listens for incoming messages and response with
`:pong`. `Ping` is initialized with an integer indicating the number of `:ping`
messages it's allowed to send. When it sends that many messages it sends `:stop`
and shuts itself down. When `Pong` receives a `:stop` message it shuts itself
down.

The main program simply creates two objects: one `Ping` and one `Pong`. It
starts each of these actors on a new thread (there are more sophisticated ways
to run an `Actor` but we're keeping things simple), starts the game by sending a
`:pong` message to the `Ping` object, then joins the two threads until the two
`Actor` instances finish and their individual threads exit.

### Run It

This example can be run from the console. From the root of the repo run:

> $ actor-ping-pong/ping-pong.rb

The output should be sonething like this:

```
Ping: pong 10000
Pong: ping 0
Pong: ping 1000
Ping: pong 9000
Pong: ping 2000
Ping: pong 8000
Pong: ping 3000
Ping: pong 7000
Pong: ping 4000
Ping: pong 6000
Pong: ping 5000
Ping: pong 5000
Pong: ping 6000
Ping: pong 4000
Pong: ping 7000
Ping: pong 3000
Pong: ping 8000
Ping: pong 2000
Pong: ping 9000
Ping: pong 1000
Pong: ping 10000
Ping: pong 0
Ping :stop
Pong: ping 11000
Pong: ping 12000
Pong: ping 13000
Pong: ping 14000
Pong: ping 15000
Pong: ping 16000
Pong: ping 17000
Pong: ping 18000
Pong: ping 19000
Pong: ping 20000
Pong :stop 
```

### The Ruby Code

```ruby
require 'concurrent'

class Ping < Concurrent::Actor

  def initialize(count, pong)
    super()
    @pong = pong
    @remaining = count
  end

  def act(msg)

    if msg == :pong
      print "Ping: pong #{@remaining}\n" if @remaining % 1000 == 0
      @pong.post(:ping)

      if @remaining > 0
        @pong << :ping
        @remaining -= 1
      else
        print "Ping :stop\n"
        @pong << :stop
        self.stop
      end
    end
  end
end

class Pong < Concurrent::Actor

  attr_writer :ping

  def initialize
    super()
    @count = 0
  end

  def act(msg)

    if msg == :ping
      print "Pong: ping #{@count}\n" if @count % 1000 == 0
      @ping << :pong
      @count += 1

    elsif msg == :stop
      print "Pong :stop\n"
      self.stop
    end
  end
end

pong = Pong.new
ping = Ping.new(10000, pong)
pong.ping = ping

t1 = Thread.new { ping.run }
t2 = Thread.new { pong.run }

ping << :pong

t1.join
t2.join
```
