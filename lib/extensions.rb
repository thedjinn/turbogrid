require "action_view"

module TurboGrid
  module ActionViewExtensions
    extend ActiveSupport::Concern

    module InstanceMethods
      def render_grid grid
        Renderer.new(self, grid).render
      end
    end
  end

  module ActionControllerExtensions
    extend ActiveSupport::Concern

    module InstanceMethods
      def grid_for scope, &block
        raise ArgumentError, "Missing block" unless block_given?

        GridBuilder.new scope, params, &block
      end
    end
  end
end

ActionController::Base.send :include, ::TurboGrid::ActionControllerExtensions
ActionView::Base.send :include, ::TurboGrid::ActionViewExtensions
