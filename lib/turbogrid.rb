require "renderer"
require "extensions"

require "kaminari"

module TurboGrid
  class Column
    attr_reader :options
    attr_reader :name
    attr_reader :field

    def initialize field, name, options={}, &block
      @name = name
      @field = field
      @block = block
      @options = options
    end

    def content_for record
      value = record.send(@field)
      if @block then @block.call(value) else value end
    end

    def sort_link
      {
        :sort_by => @field,
        :sort_dir => if @options[:sort] == "asc" then "desc" else "asc" end
      }
    end
  end

  class SelectFilter
    attr_accessor :field
    attr_accessor :name
    attr_accessor :choices
    attr_accessor :value

    def initialize field, name, choices, namespace
      @field = field
      @name = name
      @choices = choices
      @namespace = namespace
    end

    def input_name
      "#{@namespace}[#{@field}]"
    end

    def perform scope
      if @value && !@value.empty?
        scope.where("#{@field} = ?", @value)
      else
        scope
      end
    end
  end

  class GridBuilder
    attr_reader :columns
    attr_reader :filters
    attr_reader :scope

    def initialize scope, params, &block
      raise ArgumentError, "Missing block" unless block_given?

      @columns = []
      @filters = []
      @namespace = "#{scope.model_name.underscore}_grid"
      @options = params[@namespace] || {}
      @scope = scope.scoped.page(@options[:page]).per(20)

      # delete the page option so that kaminari properly creates links
      @options.delete :page

      if @options[:sort_by]
        @options[:sort_dir] = if @options[:sort_dir] == "desc" then "desc" else "asc" end
        @scope = @scope.order("#{@options[:sort_by]} #{@options[:sort_dir]}")
      end

      instance_eval &block

      @filters.each do |filter|
        @scope = filter.perform @scope
      end
    end

    def link_for options
      { @namespace => options }
    end

    def filter_path
      link_for @options
    end

    def filter_options
      options = {}

      options["#{@namespace}[sort_dir]"] = @options[:sort_dir] if @options[:sort_dir]
      options["#{@namespace}[sort_by]"] = @options[:sort_by] if @options[:sort_by]

      options
    end

    def pagination_options
      {
        :param_name => "#{@namespace}[page]"
      }
    end

    # DSL methods below

    def column field, name=nil, options={}, &block
      name = name || @scope.human_attribute_name(field)

      if @options[:sort_by] == field.to_s
        options[:sort] = @options[:sort_dir]
      end

      @columns << Column.new(field, name, options, &block)
    end

    def select_filter field, name, choices
      choices = [["", ""]] + choices.to_a
      filter = SelectFilter.new(field, name, choices, @namespace)
      value = @options[field.to_s]
      filter.value = value if filter.choices.detect { |choice| choice[1] == value }
      @filters << filter
    end
  end
end
