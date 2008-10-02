require 'ms/in_silico/spectrum'

module Ms
  module InSilico
    
    # Ms::InSilico::Fragment::manifest calculates a theoretical ms/ms spectrum
    #
    # Calculates a theoretical ms/ms spectrum from a peptide sequence.
    # Configurations allow the specification of one or more fragmentation 
    # series to include, as well as charge, and intensity.  The resulting
    # data is not sorted.
    #
    #   % rap predict TVQQEL --+ dump --no-audit
    #   # date: 2008-09-15 14:37:55
    #   --- 
    #   ms/in_silico/fragment (:...:): 
    #   - - 717.377745628191
    #     - - 717.377745628191
    #       - 616.330067154091
    #       - 517.261653237891
    #       - 389.203075726491
    #       - 261.144498215091
    #       - 132.101905118891
    #       - 102.054954926291
    #       - 201.123368842491
    #       - 329.181946353891
    #       - 457.240523865291
    #       - 586.283116961491
    #       - 699.367180941891
    #
    class Fragment < Tap::Task
      
      # A block to validate a config input
      # is an EmpericalFormula.
      MOLECULE = lambda do |value|
        case value
        when Molecules::EmpiricalFormula then value
        else Molecules::EmpiricalFormula.parse(value)
        end
      end
      
      config :series, ['y', 'b'], &c.array   # a list of the series to include
      config :charge, 1, &c.integer          # the charge for the parent ion
      config :intensity, nil, &c.num_or_nil  # a uniform intensity value
      config :nterm, 'H', &MOLECULE          # the n-terminal modification
      config :cterm, 'OH', &MOLECULE         # the c-terminal modification
      config :sort, true, &c.switch          # sorts the data by mass
      
      def process(peptide)
        log :fragment, peptide
        spec = spectrum(peptide)
        
        masses = []
        series.each {|s| masses.concat(spec.series(s)) }
        masses.sort! if sort
        masses.collect! {|m| [m, intensity] } if intensity
        
        [spec.parent_ion_mass(charge), masses]
      end
      
      protected
      
      # Returns a new Spectrum used in the calculation.
      # Primarily a hook for custom spectra in subclasses.
      def spectrum(peptide)
        Spectrum.new(peptide, nterm, cterm)
      end
      
    end 
  end
end