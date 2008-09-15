require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'ms/in_silico/digester'

class DigesterTest < Test::Unit::TestCase
  include Ms::InSilico
  include Tap::Test::SubsetMethods
  
  attr_accessor :digester
  def setup
    @digester = Digester.new('arg', 'R')
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
  
  #
  # fragment_sites
  #
  
  def test_fragment_sites_documentation
    d = Digester.new('trypsin', 'KR', 'P')
    assert_equal [0, 1, 4], d.fragment_sites("RGGR")
    assert_equal [0, 9], d.fragment_sites("RPPGFSPFR")
    assert_equal [0, 3, 8, 16, 19], d.fragment_sites("..K..RPR..K\nPK\n\s...")
  end
  
  def test_fragment_sites
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
   }.each_pair  do |sequence, expected|
      assert_equal expected, digester.fragment_sites(sequence), sequence
    end
  end

  def test_fragment_sites_with_exception
    @digester = Digester.new('argp', 'R', 'P')
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
    }.each_pair  do |sequence, expected|
      assert_equal expected, digester.fragment_sites(sequence), sequence
    end
  end
  
  def test_fragment_sites_with_offset_and_limit
    {
      "RxxR" => [2,4],
      "RxAxR" => [2,4],
      "RxAAAxR" => [2,4],
      "RxRRRxR" => [2,3,4]
    }.each_pair do |sequence, expected|
      assert_equal expected, digester.fragment_sites(sequence, 2, 2), sequence
    end
  end
  
  def test_fragment_sites_speed
    benchmark_test(20) do |x|
      str = nk_string(10, 1000)
       assert_equal 11, digester.fragment_sites(str).length
      
      x.report("10kx - fragments") do 
        10000.times { digester.fragment_sites(str) }
      end
    end
  end

  #
  # digest
  #

  def test_digest
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
    }.each_pair do |sequence, expected|
      assert_equal expected, digester.digest(sequence) {|frag, s, e| frag}, spp(sequence)
    end
  end

  def test_digest_with_missed_cleavage
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
    }.each_pair do |sequence, expected|
      assert_equal expected, digester.digest(sequence, 1) {|frag, s, e| frag}, sequence
    end
  end
  
    
  def test_digest_with_two_missed_cleavages
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
    }.each_pair do |sequence, expected|
      assert_equal expected, digester.digest(sequence, 2) {|frag, s, e| frag}, sequence
    end
  end
  
  def test_digest_speed
    benchmark_test(20) do |x|
      str = nk_string(10, 1000)
       assert_equal 10, digester.digest(str).length
      
      x.report("10kx - fragments") do 
        10000.times { digester.digest(str) }
      end
    end
  end

  #
  # site digest
  #
  
  def test_site_digest
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
    }.each_pair do |sequence, expected|
      assert_equal expected, digester.site_digest(sequence), sequence
    end
  end
  
  def test_site_digest_with_missed_cleavage
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
    }.each_pair do |sequence, expected|
      assert_equal expected, digester.site_digest(sequence, 1), sequence
    end
  end
  
  def test_site_digest_with_two_missed_cleavages
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
    }.each_pair do |sequence, expected|
      assert_equal expected, digester.site_digest(sequence, 2), sequence
    end
  end
  
  def test_site_digest_speed
    benchmark_test(20) do |x|
      str = nk_string(10, 1000)
       assert_equal 10, digester.site_digest(str).length
      
      x.report("10kx - fragments") do 
        10000.times { digester.site_digest(str) }
      end
    end
  end
  
  #
  # trypsin
  #
  
  def test_trypsin_digest
    trypsin = Digester::TRYPSIN
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
    }.each_pair do |sequence, expected|
      assert_equal expected, trypsin.digest(sequence) {|frag, s, e| frag}, sequence
    end
  end
 
end