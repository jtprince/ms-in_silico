require 'spec_helper.rb'

require 'ms/in_silico/fragment'

describe 'creating fragmentation spectra' do

  it 'creates tandem mass spectra from a peptide' do
    frag = Ms::InSilico::Fragment.new :charge => 1, :series => ['b']
    spec = Ms::InSilico::Spectrum.new('TVQQEL', 'H', 'HO')
    
    headers = frag.headers(spec)
    headers[:charge].is 1
    headers[:nterm].is 'H'
    headers[:cterm].is 'HO'
    headers[:parent_ion_mass].should.be.close 717.377745628191, 0.000000000001
    headers[:series].is ['b']
  end
end
  
