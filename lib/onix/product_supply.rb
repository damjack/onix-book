require 'onix/price'

module ONIX

  class MarketDate < Subset
    attr_accessor :role, :date
    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("MarketDateRole")
            @role = MarketDateRole.from_code(t.text)
          when tag_match("Date")
            # via OnixDate
          else
            unsupported(t)
        end
      end
      @date=OnixDate.parse(n)

    end
  end

  class Market < Subset
    attr_accessor :territory

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("Territory")
            @territory=Territory.parse(t)
          else
            unsupported(t)
        end
      end
    end
  end

  class MarketPublishingDetail < Subset
    attr_accessor :publisher_representatives, :market_dates

    def initialize
      @publisher_representatives=[]
      @market_dates = []
    end

    def availability_date
      av=@market_dates.select{|sd| sd.role.human=="PublicationDate" || sd.role.human=="EmbargoDate"}.first
      if av
        av.date.date
      else
        nil
      end
    end

    def parse(n)
      @publisher_representatives=Agent.parse_entities(n, "PublisherRepresentative")
      n.elements.each do |t|
        case t
          when tag_match("MarketDate")
            @market_dates << MarketDate.parse(t)
          else
            unsupported(t)
        end
      end
    end

  end

  class SupplyDate < Subset
    attr_accessor :role, :date
    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("SupplyDateRole")
            @role = SupplyDateRole.from_code(t.text)
          when tag_match("Date")
            # via OnixDate
          else
            unsupported(t)
        end
      end
      @date = OnixDate.parse(n)

    end
  end

  class SupplyDetail < Subset
    attr_accessor :availability, :suppliers, :supply_dates, :prices

    def initialize
      @suppliers=[]
      @supply_dates=[]
      @prices=[]
    end

    def distributors
      @suppliers.select{|s| s.role.human=~/Distributor/}.uniq
    end

    def available?
      ["Available","NotYetAvailable","InStock","ToOrder","Pod"].include?(@availability.human)
    end

    def sold_separately?
      @availability.human!="NotSoldSeparately"
    end

    def availability_date
      av=@supply_dates.select{|sd| sd.role.human=="ExpectedAvailabilityDate" || sd.role.human=="EmbargoDate"}.first
      if av
        av.date.date
      else
        nil
      end
    end

    def parse(n)
      @suppliers = Supplier.parse_entities(n, "Supplier")

      n.elements.each do |t|
        case t
          when tag_match("ProductAvailability")
            @availability=ProductAvailability.from_code(t.text)
          when tag_match("SupplyDate")
            @supply_dates << SupplyDate.parse(t)
          when tag_match("Price")
            @prices << Price.parse(t)
          when tag_match("Supplier")
            # via parse_entities
          else
            unsupported(t)
        end
      end
    end
  end

  class ProductSupply < Subset
    attr_accessor :supply_details, :markets, :market_publishing_detail

    def initialize
      @supply_details=[]
      @markets=[]
    end

    def distributors
      @supply_details.map{|sd| sd.distributors}.flatten.uniq{|d| d.name}
    end

    def available_supply_details
      @supply_details.select{|sd| sd.available?}
    end

    def unavailable_supply_details
      @supply_details.delete_if{|sd| sd.available?}
    end

    def available?
      self.available_supply_details.length > 0
    end

    def parse(n)
      n.elements.each do |t|
        case t
          when tag_match("SupplyDetail")
            @supply_details << SupplyDetail.parse(t)
          when tag_match("Market")
            @markets << Market.parse(t)
          when tag_match("MarketPublishingDetail")
            @market_publishing_detail = MarketPublishingDetail.parse(t)
          else
            unsupported(t)
        end
      end
    end
  end

end