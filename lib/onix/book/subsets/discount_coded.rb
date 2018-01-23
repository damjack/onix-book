module Onix
  module Book
    module Subsets
      class DiscountCoded < SubsetDsl
        element "DiscountCodeType", :text
        element "DiscountCodeTypeName", :text
        element "DiscountCode", :text

        # shortcuts
        def code_type
          @discount_code_type
        end

        def code_type_name
          @discount_code_type_name
        end

        def code
          @discount_code
        end
      end
    end
  end
end