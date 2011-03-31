#!/usr/bin/env ruby

require 'optparse'
require 'ms/in_silico/digester'

def print_enzyme_names
  puts "(tab delimited)"
  puts %w(name cuts nocut cterm?).join("\t")
  Ms::InSilico::Digester::ENZYMES.each do |key, enzyme|
    puts [:name, :cleave_str, :cterm_exception, :cterm_cleavage].map {|v| enzyme.send(v) }.join("\t")
  end
end

delimiter_hash = {
  'space' => ' ',
  'tab' => "\t",
  'newline' => "\n",
}

opt = {
  :enzyme => 'Trypsin',
  :missed_cleavages => 0,
  :delimiter => 'space',
  :record_delimiter => 'newline',
}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} [OPTIONS] SOMEPROTEINSEKUENCE ..."
  op.separator "output: SOMEPR OTEINSEK UENCE"
  op.separator "options:"
  op.on("-e", "--enzyme <#{opt[:enzyme]}>", "specify a valid enzyme name") {|v| opt[:enzyme] = v }
  op.on("-m", "--missed-cleavages <#{opt[:missed_cleavages]}>", Integer, "number of missed cleavages") {|v| opt[:missed_cleavages] = v }
  op.on("-d", "--delimiter <#{opt[:delimiter]}>", "delimit the returned peptides",
        "('space','tab','newline' or some other string)") {|v| opt[:delimiter] = v }
  op.on("-r", "--record-delimiter <#{opt[:record_delimiter]}>", "included after each protein output") {|v| opt[:record_delimiter] = v }
  op.separator ""
  op.on("--print-enzymes", "prints table of valid enzyme names and exits") { print_enzyme_names ; exit }
end
opts.parse!

if ARGV.size == 0
  puts opts
  exit
end

[:delimiter, :record_delimiter].each {|k| opt[k] = (delimiter_hash[opt[k]] || opt[k]) }

ARGV.each do |protein|
  print Ms::InSilico::Digester[opt[:enzyme]].digest(protein, opt[:missed_cleavages]).join(opt[:delimiter])
  print opt[:record_delimiter]
end
