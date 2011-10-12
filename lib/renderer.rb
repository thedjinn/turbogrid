module TurboGrid
  class Renderer
    def initialize view, grid
      @view = view
      @grid = grid
    end

    def url_for options
      @view.url_for @grid.link_for(options)
    end

    def render_sort_icon mode
      sort_class = case mode
                   when "asc"
                     "sortAsc"
                   when "desc"
                     "sortDesc"
                   else
                     "sort"
                   end
      @view.content_tag :span, "", :class => ["ico", sort_class]
    end

    def render_column_header column
      @view.content_tag :th do
        @view.link_to(url_for(column.sort_link)) do
          render_sort_icon(column.options[:sort]) + column.name
        end
      end
    end

    def render_column_field column, record
      content = column.content_for record

      if column.url
        content = @view.link_to(content, column.url.call(record))
      end

      @view.content_tag :td, content
    end

    def render_row row
      @view.content_tag :tr do
        @grid.columns.map do |column|
          render_column_field column, row
        end.join.html_safe
      end
    end

    def render_thead
      @view.content_tag :thead do
        @view.content_tag :tr do
          @grid.columns.map { |column| render_column_header column }.join.html_safe
        end
      end
    end

    def render_tbody
      @view.content_tag :tbody do
        @grid.scope.map do |row|
          render_row row
        end.join.html_safe
      end
    end

    def render_tfoot
      @view.content_tag :tfoot do
        "<tr><td>footer</td></tr>".html_safe
      end
    end

    def render_table
      @view.content_tag :table do
        render_thead + render_tbody + render_tfoot
      end
    end

    def render_select_filter filter
      @view.select_tag filter.input_name, @view.options_for_select(filter.choices, filter.value)
    end

    def render_filter
      return "".html_safe if @grid.filters.empty?

      @view.form_tag @grid.filter_path, :method => :get, :class => "filter" do
        @grid.filter_options.map do |key, value|
          @view.hidden_field_tag(key, value)
        end.join.html_safe +
        render_select_filter(@grid.filters.first) +
        @view.submit_tag("Go")
      end
    end

    def render
      render_filter + render_table + @view.paginate(@grid.scope, @grid.pagination_options)
    end
  end
end
