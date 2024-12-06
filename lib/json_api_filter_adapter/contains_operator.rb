module JsonApiFilterAdapter
  class ContainsOperator
    class << self
      def process(q)
        [template(q), "%#{q[:values]}%"]
      end

      def template(q)
        ":attribute like ?".gsub(":attribute", q[:attribute])
      end
    end
  end
end
