require_relative 'setup'
require 'leafy/metrics/registry'
require 'leafy/metrics/jruby_metrics'

describe Leafy::Metrics::JRubyMetrics do

  subject do
    r = Leafy::Metrics::Registry.new
    Leafy::Metrics::JRubyMetrics.register_ruby_thread_state_gauges( r, 'test' )
    Leafy::Metrics::JRubyMetrics.register_object_allocation_meters( r, 'test' )
    r
  end

  it 'registers and unregister a meter' do

    expect( subject.metrics.gauges['test.total.count'].value ).to eq 1
    expect( subject.metrics.gauges['test.executing.count'].value ).to eq 1
    expect( subject.metrics.gauges['test.sleeping.count'].value ).to eq 0
  end

  it 'registers object allocation meters' do
    if JRUBY_VERSION < '1.7.20' or JRUBY_VERSION == '9.0.0.0-pre1'
      skip( 'unsupported jruby version for object allocation meters' )
    end

    total = subject.metrics.meters[ 'test.total' ].count 

    hashes = 0
    symbols = 4
    arrays = 1
    strings = 16

    expect( subject.metrics.meters[ 'test.strings' ].count ).to eq strings
    expect( subject.metrics.meters[ 'test.symbols' ].count ).to eq symbols
    # TODO not sure why there is no fixnum increments
    expect( subject.metrics.meters[ 'test.fixnums' ].count ).to eq 0
    expect( subject.metrics.meters[ 'test.hashes' ].count ).to eq hashes
    expect( subject.metrics.meters[ 'test.arrays' ].count ).to eq arrays

    total1 = subject.metrics.meters[ 'test.total' ].count 
    
    h = { :asd => 123, :dsa => 321 }

    expect( subject.metrics.meters[ 'test.strings' ].count ).to eq strings + 9
    expect( subject.metrics.meters[ 'test.arrays' ].count ).to eq arrays
    expect( subject.metrics.meters[ 'test.hashes' ].count ).to eq hashes + 1
    expect( subject.metrics.meters[ 'test.symbols' ].count ).to eq symbols + 2
    
    total2 = subject.metrics.meters[ 'test.total' ].count

    h = [ :asd, :dsa ]

    expect( subject.metrics.meters[ 'test.strings' ].count ).to eq strings + 14
    expect( subject.metrics.meters[ 'test.hashes' ].count ).to eq hashes + 1
    expect( subject.metrics.meters[ 'test.symbols' ].count).to eq symbols + 2
    expect( subject.metrics.meters[ 'test.arrays' ].count ).to eq arrays + 1
 
    s = subject.metrics.meters[ 'test.strings' ].count

    h = 'aha'

    # TODO not sure why there is an increment of 2 here
    expect( subject.metrics.meters[ 'test.strings' ].count ).to eq s + 2
    expect( subject.metrics.meters[ 'test.hashes' ].count ).to eq hashes + 1
    expect( subject.metrics.meters[ 'test.symbols' ].count).to eq symbols + 2
    expect( subject.metrics.meters[ 'test.arrays' ].count ).to eq arrays + 1

    expect( total1 ).to be > total
    expect( total2 ).to be > total1  
    expect( subject.metrics.meters[ 'test.total' ].count ).to be > total2
  end
end
