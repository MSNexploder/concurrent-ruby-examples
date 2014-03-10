require 'concurrent'

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
