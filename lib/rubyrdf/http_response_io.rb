module RubyRDF
  class HTTPResponseIO
    def initialize()
      @semaphore = Mutex.new
      @eos = false
      @buffer = StringIO.new
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

    def getc
      wait(2)
      @semaphore.synchronize {
        @buffer.getc
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
