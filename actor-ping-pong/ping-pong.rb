require 'concurrent'
require_relative 'ping'
require_relative 'pong'

pong = Pong.new
ping = Ping.new(10000, pong)
pong.ping = ping

t1 = Thread.new { ping.run }
t2 = Thread.new { pong.run }

ping << :pong

t1.join
t2.join
