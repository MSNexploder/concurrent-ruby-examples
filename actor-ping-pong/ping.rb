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
