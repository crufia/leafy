require_relative 'setup'

require 'leafy/instrumented/instrumented'

describe Leafy::Instrumented::Instrumented do

  subject { Leafy::Instrumented::Instrumented.new( registry, "name" ) }
 
  let( :registry ) { Leafy::Metrics::Registry.new }

  let( :app ) do
    Proc.new() do
      sleep 0.1
      [ 200, nil, registry.metrics.counters.values.first.count ]
    end
  end

  it 'collects metrics for a call' do
    _, _, count = subject.call do
      app.call
    end
    expect( count ).to eq 1
    expect( registry.metrics.timers.keys ).to eq [ 'name.requests' ]
    expect( registry.metrics.timers.values.first.mean_rate ).to be > 0.9
    expect( registry.metrics.counters.keys ).to eq [ 'name.active_requests' ]
    expect( registry.metrics.counters.values.collect { |a| a.count } ).to eq [ 0 ]
  end

  [ 400, 201, 204, 404, 200, 123, 205, 500 ].each_with_index do |status, index|
    it "collects metrics for a call for status #{status}" do
      result, _, _ = subject.call do
        sleep 0.01
        [ status, nil, nil ]
      end

      expect( result ).to eq status

      expect( registry.metrics.timers.keys ).to eq [ 'name.requests' ] 
      expect( registry.metrics.timers.values.first.mean_rate ).to be > 0.09

      expect( registry.metrics.counters.keys ).to eq [ 'name.active_requests' ]
      expect( registry.metrics.counters.values.collect { |a| a.count } ).to eq [ 0 ]
      
      expect( registry.metrics.meters.keys.sort ).to eq [ 'name.responseCodes.badRequest', 'name.responseCodes.created', 'name.responseCodes.noContent', 'name.responseCodes.notFound', 'name.responseCodes.ok', 'name.responseCodes.other', 'name.responseCodes.resetContent', 'name.responseCodes.serverError' ]

      stati = registry.metrics.meters.values.collect { |a| a.count }
      expect( stati[ index ] ).to eq 1

      expected = [0,0,0,0,0,0,0,0]
      expected[ index ] = 1
      expect( stati ).to eq expected

      expect( registry.metrics.meters.values.to_a[ index ].mean_rate ).to be > 50
    end
  end
end
