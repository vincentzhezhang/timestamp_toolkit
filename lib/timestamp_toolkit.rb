# encoding: utf-8

# TODO should add conditional active_record treatment
# TODO should require some library to help deal with tense
#
require 'timestamp_tookit/states'
require 'timestamp_tookit/verbs'

module TimestampToolkit
  LIBNAME = 'timestamp_toolkit'

  class << self
    def included(base)
      base.extend ClassMethods
    end
  end

  module ClassMethods
    def extract_options(options, key)
      return unless options.present?
      send("extract_#{key}", options)
    end

    def extract_columns(options)
      params, hashes = options.group_by{|a| a.is_a?(Hash) ? 1 : 0}.sort_by(&:first).map(&:last)

      @columns ||= columns.collect {|c| c.name if c.type == :datetime}.compact
      if (hashes[:only] || params)
        @columns && (hashes[:only] || params)
      elsif hashes[:except]
        @columns - hashes[:except]
      end
    end

    def extract_toolkit(options)
      options.select!{ |a| a.is_a?(Hash) && a.has_key?(:toolkit) }[0]
      @type_options ||= %i[actions states]
      if options[:only]
        @types_options && options[:only]
      elsif options[:except]
        @types_options - options[:except]
      end
    end

    def timestamp_tookit(options = {})
      timestamp_columns = extract_options(options, :columns)
      toolkit_types = extract_options(options, :toolkit)

      toolkit_types.each do |type, options|
        send("add_#{type}", timestamp_columns, options)
      end
    end
  end
end
