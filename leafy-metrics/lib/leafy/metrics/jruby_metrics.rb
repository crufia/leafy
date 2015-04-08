require 'leafy/metrics'
require 'leafy-metrics.jar'

module Leafy
  module Metrics
    module JRubyMetrics

      # registers a few thread gauges under the given basename: total.com, executing.count and sleeping.count
      #
      # @param [Leafy::Metrics::Registry] where to register the metrics
      # @param [String] basename
      def self.register_ruby_thread_state_gauges( registry, name )
        registry.register_gauge( name + '.total.count' ) do
          Thread.list.size
        end

        registry.register_gauge( name + '.executing.count' ) do
          Thread.list.select { |t| t.status == 'run' }.size
        end

        registry.register_gauge( name + '.sleeping.count' ) do
          Thread.list.select { |t| t.status == 'sleep' }.size
        end
      end

      def self.register_object_allocation_meters( registry, name )
        r = JRuby.runtime
        f = r.java_class.declared_field 'objectSpacer'
        f.accessible = true
        o = f.value( r )
        metrics = com.lookout.leafy.metrics.AllocateMetricsObjectSpacer.new
        f.set_value( r, metrics )
        registry.register_meter( name + ".strings", metrics.string )
        registry.register_meter( name + ".symbols", metrics.symbol )
        registry.register_meter( name + ".fixnums", metrics.fixnum )
        registry.register_meter( name + ".arrays", metrics.array )
        registry.register_meter( name + ".hashes", metrics.hash )
        registry.register_meter( name + ".total", metrics.total )
        true
      rescue => e
        if JRUBY_VERSION.starts_with?( '1.7.1' )
          warn 'need jruby version 1.7.20 or newer'
        else
          puts e.message
          puts e.backtrace
          warn 'can not register object allocation meters'
        end
        false
      end
    end
  end
end
