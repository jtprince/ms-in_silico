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
    hash = {'P' => [1, 2, 6], 'S' => [5]}
    Subclass.new('RPPGFSPFR').residue_locations.is hash
  end
  
=begin
  def test_locate_calls_are_cumulative
    assert_equal "PS", Cumulative.residues_to_locate
    
    Cumulative.locate_residues "R"
    assert_equal "PSR", Cumulative.residues_to_locate
    
    Cumulative.locate_residues "G"
    assert_equal "PSRG", Cumulative.residues_to_locate
  end
  
  #
  # series test
  #
  
  def test_series_documentation
    f = Spectrum.new 'RPPGFSPFR' 
    assert_equal f.series('y'), f.y_series
    assert_equal f.series('b++'), f.b_series(2)
    assert_equal f.series('nladder-'), f.nladder_series(-1)
  end
  
  def test_series_can_specify_charge
    f = Spectrum.new 'RPPGFSPFR' 
    assert_equal f.series('y'), f.y_series
    
    assert_equal f.series('y-'), f.y_series(-1)
    assert_equal f.series('y--'), f.y_series(-2)
    
    assert_equal f.series('y+'), f.y_series(1)
    assert_equal f.series('y++'), f.y_series(2)
    
    assert_equal f.series('y++---'), f.y_series(-1)
  end
  
  def test_series_raises_error_for_zero_charge_and_unknown_series
    f = Spectrum.new('SAMPLE')
    assert_raise(ArgumentError) { f.series 'y+-' }
    assert_raise(ArgumentError) { f.series 'q' }
  end
  
  def test_sequences_may_contain_whitespace
    s = Spectrum.new('SAMPLE')
    s1 = Spectrum.new(" SA\n  MPL\t \rE  ")
    assert_equal s.series('y'), s1.series('y')
  end
  
  #
  # benchmarks
  #
  
  def test_fragment_speed
    benchmark_test(20) do |x|
      x.report("1k RPPGFSPFR * 10") { 1000.times { Spectrum.new("RPPGFSPFR" * 10) } }
    end
  end
=end

end
