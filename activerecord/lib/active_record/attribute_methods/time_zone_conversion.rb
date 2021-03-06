module ActiveRecord
  module AttributeMethods
    module TimeZoneConversion
      class Type < SimpleDelegator # :nodoc:
        def type_cast_from_database(value)
          convert_time_to_time_zone(super)
        end

        def type_cast_from_user(value)
          if value.is_a?(Array)
            value.map { |v| type_cast_from_user(v) }
          elsif value.respond_to?(:in_time_zone)
            value.in_time_zone
          end
        end

        def convert_time_to_time_zone(value)
          if value.is_a?(Array)
            value.map { |v| convert_time_to_time_zone(v) }
          elsif value.acts_like?(:time)
            value.in_time_zone
          else
            value
          end
        end
      end

      extend ActiveSupport::Concern

      included do
        mattr_accessor :time_zone_aware_attributes, instance_writer: false
        self.time_zone_aware_attributes = false

        class_attribute :skip_time_zone_conversion_for_attributes, instance_writer: false
        self.skip_time_zone_conversion_for_attributes = []
      end

      module ClassMethods
        private
        def create_time_zone_conversion_attribute?(name, column)
          time_zone_aware_attributes &&
            !self.skip_time_zone_conversion_for_attributes.include?(name.to_sym) &&
            (:datetime == column.type)
        end
      end
    end
  end
end
