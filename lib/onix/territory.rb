require 'onix/code'
module ONIX
  class Territory < Subset
    attr_accessor :countries_included, :regions_included, :countries_excluded, :region_excluded
    def parse(t)
      @countries_included=Helper.text_at(t,"./CountriesIncluded")
      @regions_included=Helper.text_at(t,"./RegionsIncluded")
      @countries_excluded=Helper.text_at(t,"./CountriesExcluded")
      @regions_excluded=Helper.text_at(t,"./RegionsExcluded")
    end

    def countries
      countries=[]
      if @countries_included
        countries+=@countries_included.split(" ")
      end
      if @regions_included
        countries+=@regions_included.split(" ").map{|region| self.class.region_to_countries(region)}.flatten.uniq
      end
      if @countries_excluded
        countries-=@countries_excluded.split(" ")
      end
      if @regions_excluded
        countries-=@regions_excluded.split(" ").map{|region| self.class.region_to_countries(region)}.flatten.uniq
      end
      countries.uniq.sort
    end

    def worldwide?
      self.class.worldwide?(self.countries)
    end

    def self.worldwide?(countries)
      (countries & CountryCode.list).length==CountryCode.list.length
    end

    def countries=v
      if (v.uniq & CountryCode.list).length==CountryCode.list.length
        @regions_included="WORLD"
      else
        @countries_included=v.uniq.join(" ")
      end
    end

    def self.region_to_countries(region)
      case region
        when "WORLD"
          CountryCode.list
        when "ECZ"
          ["AT","BE","CY","EE","FI","FR","DE","ES","GR","IE","IT",
           "LU","MT","NL","PT","SI","SK","AD","MC","SM","VA","ME"]
        else
          []
      end
    end

  end
end