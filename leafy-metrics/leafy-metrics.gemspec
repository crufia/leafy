#-*- mode: ruby -*-

require File.expand_path( '../lib/leafy/metrics/version', __FILE__ )

Gem::Specification.new do |s|
  s.name = 'leafy-metrics'
  s.version = Leafy::Metrics::VERSION
  s.author = 'christian meier'
  s.email = [ 'christian.meier@lookout.com' ]
  s.platform = 'java'
  
  s.platform = 'java'
  s.license = 'MIT'
  s.summary = %q(provide an API to register metrics)
  s.homepage = 'https://github.com/lookout/leafy'
  s.description = %q(provides an API to register metrics like meters, timers, gauge, counter using dropwizard-metrics. it also allows to setup reporters: console-reporter, csv-reporter and graphite-reporter)
  
  s.files = `git ls-files`.split($/)

  METRICS_VERSION = '3.1.0'
  s.requirements << "jar io.dropwizard.metrics:metrics-core, #{METRICS_VERSION}"
  s.requirements << "jar io.dropwizard.metrics:metrics-graphite, #{METRICS_VERSION}"
  s.requirements << "jar io.dropwizard.metrics:metrics-jvm, #{METRICS_VERSION}"
  s.requirements << "jar org.slf4j, slf4j-simple, 1.7.7, :scope => :test"
  s.requirements << "jar org.jruby:jruby-core, 1.7.20-SNAPSHOT, :scope => :provided"
  s.requirements << "jar org.jruby:jruby-stdlib, 1.7.20-SNAPSHOT, :scope => :provided"

  s.add_runtime_dependency 'jar-dependencies', '~> 0.1.8'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'yard', '~> 0.8.7'
  s.add_development_dependency 'rake', '~> 10.2'
end

# vim: syntax=Ruby
