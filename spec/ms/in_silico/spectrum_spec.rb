require File.dirname(__FILE__) + '/../../spec_helper'
require 'ms/in_silico/spectrum'

# class locate_residues tests
class Subclass < Ms::InSilico::Spectrum
  locate_residues "PS"
end

class Cumulative < Ms::InSilico::Spectrum
  locate_residues "PS"
end


describe 'creating spectral fragmentation ladders' do
  
  it 'locates residues' do
    Subclass.new('RPPGFSPFR').residue_locations.is( {'P' => [1, 2, 6], 'S' => [5]} )
  end
  
  it 'does cumulative locate calls' do
    Cumulative.residues_to_locate.is "PS"
    Cumulative.locate_residues "R"
    Cumulative.residues_to_locate.is "PSR"

    Cumulative.locate_residues "G"
    Cumulative.residues_to_locate.is "PSRG"
  end

  it 'creates spectral series' do
    f = Ms::InSilico::Spectrum.new 'RPPGFSPFR' 
    f.y_series.is f.series('y')
    f.b_series(2).is f.series('b++')
    f.nladder_series(-1).is f.series('nladder-')
  end

  it 'specifies charges' do
    f = Ms::InSilico::Spectrum.new 'RPPGFSPFR' 
    f.y_series.is f.series('y')

    f.y_series(-1).is f.series('y-')
    f.y_series(-2).is f.series('y--')

    f.y_series(1).is f.series('y+')
    f.y_series(2).is f.series('y++')

    f.y_series(-1).is f.series('y++---')
  end

  it 'raises an error for zero charge or unknown series' do
    f = Ms::InSilico::Spectrum.new('SAMPLE')
    lambda { f.series 'y+-' }.should.raise ArgumentError
    lambda { f.series 'q' }.should.raise ArgumentError
  end

  it 'handles whitespace in the peptide spec' do
    s = Ms::InSilico::Spectrum.new('SAMPLE')
    s1 = Ms::InSilico::Spectrum.new(" SA\n  MPL\t \rE  ")
    s1.series('y').is s.series('y')
  end

  it 'is fast' do
    1.is 1
    benchmark(20) do |x|
      x.report("1k RPPGFSPFR * 10") { 1000.times { Ms::InSilico::Spectrum.new("RPPGFSPFR" * 10) } }
    end
  end

end
