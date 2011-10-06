require "renderer"
require "extensions"

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

  class GridBuilder
    attr_reader :columns
    attr_reader :scope

    def initialize scope, params, &block
      raise ArgumentError, "Missing block" unless block_given?

      @scope = scope.scoped
      @columns = []
      @namespace = "#{scope.model_name.underscore}_grid"
      @options = params[@namespace]

      if @options[:sort_by]
        @options[:sort_dir] = if @options[:sort_dir] == "desc" then "desc" else "asc" end
        @scope = @scope.order("#{@options[:sort_by]} #{@options[:sort_dir]}")
      end

      instance_eval &block
    end

    def link_for options
      { @namespace => options }
    end

    def column field, name=nil, options={}, &block
      name = name || @scope.human_attribute_name(field)

      if @options[:sort_by] == field.to_s
        options[:sort] = @options[:sort_dir]
      end

      @columns << Column.new(field, name, options, &block)
    end
  end
end
