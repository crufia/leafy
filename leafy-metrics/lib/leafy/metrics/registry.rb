require 'leafy/metrics'
module Leafy
  module Metrics

    class Gauge
      include com.codahale.metrics.Gauge
    end

    class Registry

      class Timer

        attr_reader :timer

        def initialize( timer )
          @timer = timer
        end
        
        def time( &block )
          context = @timer.time
          
          yield
          
        ensure
          context.stop
        end
      end
      
      class GaugeWrapper < Leafy::Metrics::Gauge
        
        def initialize( block )
          @block = block
        end
        
        def value
          @block.call
        end
      end

      # state ofthe registry
      attr_reader :metrics
      
      def initialize
        @metrics = com.codahale.metrics.MetricRegistry.new
      end
      
      # register a gauge under a given name
      # 
      # @param [String] name
      # @param [String] instead of block any gauge object which responds to 'call'
      # @yieldreturn [Object] can be any object like Fixnum, String, Float
      # @return [MetricsRegistry::Gauge] gauge object which has a 'value' method to retrieve the current value
      def register_gauge( name, gauge = nil, &block )
        if gauge and not block_given? and gauge.respond_to? :call
          @metrics.register( name, GaugeWrapper.new( gauge ) )
        elsif gauge and not block_given? and gauge.kind_of? com.codahale.metrics.Gauge
          @metrics.register( name, gauge )
        elsif gauge.nil? and block_given?
          @metrics.register( name, GaugeWrapper.new( block ) )
        else
          raise 'needs either a block and object with call method'
        end
      end
      
      # register a meter under a given name
      # 
      # @param [String] name
      # @return [Java::ComCodahaleMetrics::Meter] meter object which has a 'mark' method to mark the meter
      def register_meter( name, meter = nil )
        if meter
          @metrics.register( name, meter )
        else
          @metrics.meter( name )
        end
      end
      
      # register a counter under a given name
      # 
      # @param [String] name
      # @return [Java::ComCodahaleMetrics::Counter] counter object which has an 'inc' and 'dec' method
      def register_counter( name )
        @metrics.counter( name )
      end
      
      # register a timer under a given name
      # 
      # @param [String] name
      # @return [Java::ComCodahaleMetrics::Timer] timer object which has an 'context' method which starts the timer. the context has a 'stop' method to stop it.
      def register_timer( name )
        Timer.new( @metrics.timer( name ) )
      end
      
      # register a histogram under a given name
      # 
      # @param [String] name
      # @return [Java::ComCodahaleMetrics::Counter] histogram object which has an 'update' method
      def register_histogram( name )
        @metrics.histogram( name )
      end

      def register_metric( name, metric )
        @metrics.register( name, metric )
      end

      def remove( name )
        @metrics.remove( name )
      end

      def reporter_builder( clazz, &block )
        r = clazz.for_registry( @metrics )
        r.instance_eval( &block ) if block
        r
      end
    end
  end
end
