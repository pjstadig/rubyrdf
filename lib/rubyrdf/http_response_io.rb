module RubyRDF
  class HTTPResponseIO
    def initialize()
      @pos = 0
      @lineno = 1
      @semaphore = Mutex.new
      @eos = false
      @buffer = StringIO.new
      @saw_cr = false
    end

    def eof?
      @semaphore.synchronize {
        @eos && @buffer.eof?
      }
    end

    def eos=(flag)
      @semaphore.synchronize {
        @eos = flag
      }
    end

    def rewind
      @semaphore.synchronize {
        @buffer.rewind
      }
    end

    def append(data)
      @semaphore.synchronize {
        @buffer.string = @buffer.string[@buffer.pos..-1] + data
      }
    end

    def read(*a)
      length, buffer = a
      wait(length && (length.to_i + 1))

      @semaphore.synchronize {
        @buffer.read(*a)
      }
    end

    def readline(sep = $/)
      buff = StringIO.new
      begin
        char = getc.chr
        buff.write(char)
      end while char != sep
      buff.string
    end

    def lineno
      @semaphore.synchronize {
        @lineno
      }
    end

    def pos
      @semaphore.synchronize {
        @pos
      }
    end

    def getc
      wait(2)
      @semaphore.synchronize {
        @pos += 1
        c = @buffer.getc
        if c == 0xD
          @saw_cr = true
          @lineno += 1
        elsif c == 0xA && !@saw_cr
          @lineno += 1
        else
          @saw_cr = false
        end
        c
      }
    end

    private
    def wait(length = nil)
      while !size?(length); end
    end

    def size?(length = nil)
      @semaphore.synchronize {
        @buffer && (@eos || (length && (@buffer.size - @buffer.pos) >= length))
      }
    end

    def eos?
      @semaphore.synchronize {
        @eos
      }
    end
  end
end
