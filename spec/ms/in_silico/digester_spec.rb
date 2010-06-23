require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'ms/in_silico/digester'
require 'pp'

describe 'a digester' do
  before do
    @digester = Ms::InSilico::Digester.new('arg', 'R')
  end
  
  def spp(input, str="")
    PP.singleline_pp(input, str)
  end

  def nk_string(n, split)
    str = []
    count = 0
  
    (n * 1000).times do 
      count += 1
      if count < split
        str << 'A'
      else
        count = 0
        str << 'R'
      end
    end
        
    str.join('')
  end
  
  it 'performs digestion and can specify sites of digestion' do
    trypsin = Ms::InSilico::Digester['Trypsin']
    
    expected = [
    'MIVIGR',
    'SIVHPYITNEYEPFAAEK',
    'QQILSIMAG']
    trypsin.digest('MIVIGRSIVHPYITNEYEPFAAEKQQILSIMAG').is expected
    
    expected =  [
    'MIVIGR',
    'MIVIGRSIVHPYITNEYEPFAAEK',
    'SIVHPYITNEYEPFAAEK',
    'SIVHPYITNEYEPFAAEKQQILSIMAG',
    'QQILSIMAG']
    trypsin.digest('MIVIGRSIVHPYITNEYEPFAAEKQQILSIMAG', 1).is expected
    
    expected = [
    [0,6],
    [0,24],
    [6,24],
    [6,33],
    [24,33]]
    trypsin.site_digest('MIVIGRSIVHPYITNEYEPFAAEKQQILSIMAG', 1).is expected
  end
  
  it 'completely ignores whitespace inside protein sequences' do
    expected = [
    "\tMIVIGR",
    "SIVHP\nYITNEYEPFAAE K",
    "QQILSI\rMAG"]
    Ms::InSilico::Digester['Trypsin'].digest("\tMIVIGRSIVHP\nYITNEYEPFAAE KQQILSI\rMAG").is expected
  end
  
  it 'runs cleavage sites documentation' do
    d = Ms::InSilico::Digester.new('Trypsin', 'KR', 'P')
    seq = "AARGGR"
    sites = d.cleavage_sites(seq)
    sites.is [0, 3, 6]
    
    seq[sites[0], sites[0+1] - sites[0]].is "AAR"
    seq[sites[1], sites[1+1] - sites[1]].is "GGR"
    
    seq = "AAR  \n  GGR"
    sites = d.cleavage_sites(seq)
    sites.is [0, 8, 11]

    seq[sites[0], sites[0+1] - sites[0]].is "AAR  \n  "
    seq[sites[1], sites[1+1] - sites[1]].is "GGR"
  end
  
  it 'finds cleavage site indices' do
    {
      "" => [0,0],
      "A" => [0,1],
      "R" => [0,1],
      "AAA" => [0,3],
      "RAA" => [0,1,3],
      "ARA" => [0,2,3],
      "AAR" => [0,3],
      "RRA" => [0,1,2,3],
      "RAR" => [0,1,3],
      "RRR" => [0,1,2,3],
      
      "R\nR\nR" => [0,2,4,5],
      "R\n\n\nR\nR\n\n" => [0,4,6,9]
   }.each do |sequence, expected|
       @digester.cleavage_sites(sequence).is expected
    end
  end

  it 'finds cleavage sites with exception' do
    @digester = Ms::InSilico::Digester.new('argp', 'R', 'P')
    {
      "" => [0,0],
      "A" => [0,1],
      "R" => [0,1],
      "AAA" => [0,3],
      "RAA" => [0,1,3],
      "ARA" => [0,2,3],
      "AAR" => [0,3],
      "RRA" => [0,1,2,3],
      "RAR" => [0,1,3],
      "RRR" => [0,1,2,3],
      
      "PR" => [0,1,2],
      "PR" => [0,2],
      "PRR" => [0,2,3],
      "RPR" => [0,3],
      "RRP" => [0,1,3],
      "APRA" => [0,3,4],
      "ARPA" => [0,4],
      "ARPARA" => [0,5,6],
      "R\nPR\nR" => [0,5,6],
      "RP\nR\nR" => [0,5,6],
      "RP\nR\nR\n" => [0,5,7]
    }.each do |sequence, expected|
       @digester.cleavage_sites(sequence).is expected
    end
  end
  
  it 'finds cleavage sites with offset and limit' do
    {
      "RxxR" => [2,4],
      "RxAxR" => [2,4],
      "RxAAAxR" => [2,4],
      "RxRRRxR" => [2,3,4]
    }.each do |sequence, expected|
       @digester.cleavage_sites(sequence, 2, 2).is expected
    end
  end
  
  it 'finds cleavage sites fast' do
    str = nk_string(10, 1000)
     @digester.cleavage_sites(str).length.is 11
    benchmark(20) do |x|
      x.report("10kx - fragments") do 
        10000.times { @digester.cleavage_sites(str) }
      end
    end
  end

  it 'digests proteins' do
    {
      "" => [''],
      "A" => ["A"],
      "R" => ["R"],
      "AAA" => ["AAA"],
      "RAA" => ["R", "AA"],
      "ARA" => ["AR", "A"],
      "AAR" => ["AAR"],
      "RRA" => ["R", "R", "A"],
      "RAR" => ["R", "AR"],
      "RRR" => ["R", "R", "R"]
    }.each do |sequence, expected|
      # spp(sequence)
       @digester.digest(sequence) {|frag, s, e| frag}.is expected
    end
  end

  it 'digests with missed cleavages' do
    {
      "" => [''],
      "A" => ["A"],
      "R" => ["R"],
      "AAA" => ["AAA"],
      "RAA" => ["R", "RAA", "AA"],
      "ARA" => ["AR", "ARA", "A"],
      "AAR" => ["AAR"],
      "RRA" => ["R", "RR", "R", "RA", "A"],
      "RAR" => ["R", "RAR", "AR"],
      "RRR" => ["R", "RR", "R", "RR", "R"]
    }.each do |sequence, expected|
       @digester.digest(sequence, 1) {|frag, s, e| frag}.is expected
    end
  end
  
  it 'digests with two missed cleavages' do
    {
      "" => [''],
      "A" => ["A"],
      "R" => ["R"],
      "AAA" => ["AAA"],
      "RAA" => ["R", "RAA", "AA"],
      "ARA" => ["AR", "ARA", "A"],
      "AAR" => ["AAR"],
      "RRA" => ["R", "RR", "RRA", "R", "RA", "A"],
      "RAR" => ["R", "RAR", "AR"],
      "RRR" => ["R", "RR", "RRR", "R", "RR", "R"]
    }.each do |sequence, expected|
       @digester.digest(sequence, 2) {|frag, s, e| frag}.is expected
    end
  end
  
  it 'digests fast' do
    str = nk_string(10, 1000)
     @digester.digest(str).length.is 10
    benchmark(20) do |x|
      x.report("10kx - fragments") do 
        10000.times { @digester.digest(str) }
      end
    end
  end

  it 'finds sites to be digested' do
    {
      "" => [[0,0]],
      "A" => [[0,1]],
      "R" => [[0,1]],
      "AAA" => [[0,3]],
      "RAA" => [[0,1],[1,3]],
      "ARA" => [[0,2],[2,3]],
      "AAR" => [[0,3]],
      "RRA" => [[0,1],[1,2],[2,3]],
      "RAR" => [[0,1],[1,3]],
      "RRR" => [[0,1],[1,2],[2,3]]
    }.each do |sequence, expected|
       @digester.site_digest(sequence).is expected
    end
  end
  
  it 'finds sites to be digested with missed cleavages' do
    {
      "" => [[0,0]],
      "A" => [[0,1]],
      "R" => [[0,1]],
      "AAA" => [[0,3]],
      "RAA" => [[0,1],[0,3],[1,3]],
      "ARA" => [[0,2],[0,3],[2,3]],
      "AAR" => [[0,3]],
      "RRA" => [[0,1],[0,2],[1,2],[1,3],[2,3]],
      "RAR" => [[0,1],[0,3],[1,3]],
      "RRR" => [[0,1],[0,2],[1,2],[1,3],[2,3]]
    }.each do |sequence, expected|
       @digester.site_digest(sequence, 1).is expected
    end
  end
  
  it 'finds sites to be digested with two missed cleavages' do
    {
      "" => [[0,0]],
      "A" => [[0,1]],
      "R" => [[0,1]],
      "AAA" => [[0,3]],
      "RAA" => [[0,1],[0,3],[1,3]],
      "ARA" => [[0,2],[0,3],[2,3]],
      "AAR" => [[0,3]],
      "RRA" => [[0,1],[0,2],[0,3],[1,2],[1,3],[2,3]],
      "RAR" => [[0,1],[0,3],[1,3]],
      "RRR" => [[0,1],[0,2],[0,3],[1,2],[1,3],[2,3]]
    }.each do |sequence, expected|
       @digester.site_digest(sequence, 2).is expected
    end
  end
  
  it 'does site digestion fast' do
    str = nk_string(10, 1000)
     @digester.site_digest(str).length.is 10
    benchmark(20) do |x|
      x.report("10kx - fragments") do 
        10000.times { @digester.site_digest(str) }
      end
    end
  end
  
  it 'does a trypsin digest' do
    trypsin = Ms::InSilico::Digester::TRYPSIN
    {
      "" => [''],
      "A" => ["A"],
      "R" => ["R"],
      "AAA" => ["AAA"],
      "RAA" => ["R", "AA"],
      "ARA" => ["AR", "A"],
      "AAR" => ["AAR"],
      "RRA" => ["R", "R", "A"],
      "RAR" => ["R", "AR"],
      "RRR" => ["R", "R", "R"],
      "RKR" => ["R", "K", "R"],
      
      "ARP" => ["ARP"],
      "PRA" => ["PR","A"],
      "ARPARAA" => ["ARPAR", "AA"],
      "RPRRR" => ["RPR", "R", "R"]
    }.each do |sequence, expected|
       trypsin.digest(sequence) {|frag, s, e| frag}.is expected
    end
  end
 
end
