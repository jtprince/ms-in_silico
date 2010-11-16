require '/spec_helper.rb'
require 'ms/in_silico/digester'
require 'ms/in_silico/spectrum'

describe 'readme documentation' do
  
  it 'works' do
    trypsin = Ms::InSilico::Digester['Trypsin']
    peptides = trypsin.digest('MIVIGRSIVHPYITNEYEPFAAEKQQILSIMAG')
    expected = [
      'MIVIGR',
      'SIVHPYITNEYEPFAAEK',
      'QQILSIMAG']
    peptides.sort.is expected.sort
  
    spectrum = Ms::InSilico::Spectrum.new(peptides[0])
    spectrum.parent_ion_mass.should.be.close 688.417442373391, 10**-12
  
    expected = [
      132.047761058391,
      245.131825038791,
      344.200238954991,
      457.284302935391,
      514.305766658991,
      670.406877687091]
    spectrum.series('b').zip(expected) do |o,e|
      o.should.be.close e, 10**-12
    end
  end
end
