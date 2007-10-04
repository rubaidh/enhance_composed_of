module Rubaidh
  module EnhanceComposedOf
    module ValueObjectInitializerShouldTakeAHash
      def self.included(base)
        base.send(:extend, ClassMethods)
        class << base
          alias_method_chain :reader_method, :hash
        end
      end

      # Gotta copy and paste +reader_method+ lock, stock & barrel because
      # we can't just override that one wee line...  Need to watch for
      # the Rails version changing!
      module ClassMethods
        private
        def reader_method_with_hash(name, class_name, mapping, allow_nil)
          mapping = (Array === mapping.first ? mapping : [ mapping ])

          allow_nil_condition = if allow_nil
            mapping.collect { |pair| "!read_attribute(\"#{pair.first}\").nil?"}.join(" && ")
          else
            "true"
          end

          module_eval <<-end_eval
            def #{name}(force_reload = false)
              if (@#{name}.nil? || force_reload) && #{allow_nil_condition}
                @#{name} = #{class_name}.new(#{mapping.collect { |pair| ":#{pair.last} => read_attribute(\"#{pair.first}\")"}.join(", ")})
              end
              return @#{name}
            end
          end_eval
        end        
      end
    end
  end
end