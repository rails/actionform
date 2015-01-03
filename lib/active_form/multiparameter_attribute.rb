module ActiveForm
  class MultiparameterAttribute #:nodoc:
    attr_reader :object, :name, :values, :column

    def initialize(object, name, values)
      @object = object
      @name   = name
      @values = values
    end

    def read_value
      return if values.values.compact.empty?

      @column = object.model.class.reflect_on_aggregation(name.to_sym) || object.model.column_for_attribute(name)
      klass   = column.klass

      if klass == Time
        read_time
      elsif klass == Date
        read_date
      else
        read_other(klass)
      end
    end

    private

    def instantiate_time_object(set_values)
      Time.zone.local(*set_values)
    end

    def read_time
      # If column is a :time (and not :date or :timestamp) there is no need to validate if
      # there are year/month/day fields
      if column.type == :time
        # if the column is a time set the values to their defaults as January 1, 1970, but only if they're nil
        { 1 => 1970, 2 => 1, 3 => 1 }.each do |key,value|
          values[key] ||= value
        end
      else
        # else column is a timestamp, so if Date bits were not provided, error
        validate_required_parameters!([1,2,3])

        # If Date bits were provided but blank, then return nil
        return if blank_date_parameter?
      end

      max_position = extract_max_param(6)
      set_values   = values.values_at(*(1..max_position))
      # If Time bits are not there, then default to 0
      (3..5).each { |i| set_values[i] = set_values[i].presence || 0 }
      instantiate_time_object(set_values)
    end

    def read_date
      return if blank_date_parameter?
      set_values = values.values_at(1,2,3)
      begin
        Date.new(*set_values)
      rescue ArgumentError # if Date.new raises an exception on an invalid date
        instantiate_time_object(set_values).to_date # we instantiate Time object and convert it back to a date thus using Time's logic in handling invalid dates
      end
    end

    def read_other(klass)
      max_position = extract_max_param
      positions    = (1..max_position)
      validate_required_parameters!(positions)

      set_values = values.values_at(*positions)
      klass.new(*set_values)
    end

    # Checks whether some blank date parameter exists. Note that this is different
    # than the validate_required_parameters! method, since it just checks for blank
    # positions instead of missing ones, and does not raise in case one blank position
    # exists. The caller is responsible to handle the case of this returning true.
    def blank_date_parameter?
      (1..3).any? { |position| values[position].blank? }
    end

    # If some position is not provided, it errors out a missing parameter exception.
    def validate_required_parameters!(positions)
      if missing_parameter = positions.detect { |position| !values.key?(position) }
        raise ArgumentError.new("Missing Parameter - #{name}(#{missing_parameter})")
      end
    end

    def extract_max_param(upper_cap = 100)
      [values.keys.max, upper_cap].min
    end
  end
end
