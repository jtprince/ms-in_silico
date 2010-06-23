require 'rubygems'
require 'spec/more'

require 'benchmark'

Bacon.summary_on_exit

module Bacon
  class Context
    def benchmark(width=7, &block)
      if ENV['BENCHMARK']
        Benchmark.bm(width, &block) 
      end
    end
    def assert_equal(x,y)
      x.is y
    end
  end
end
