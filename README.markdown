# Turbogrid

The fastest way to add sortable tables to a Rails app.

## Features

* Only a small amount of code required
* Automatically handles sorting
* Customizable columns
* Optional filters

## Example

Let's say you have a model called `Item`. You can then make a grid for it by placing the following code in your controller:

    @grid = grid_for Item do
      # Create a column for name
      column :name

      # Create a column for category using a custom title
      column :category, "The category"

      # Create a column for price and filter each value through a block
      column :price do |value|
        "EUR #{value}"
      end

      # Add a filter for the category
      select_filter :category, "Filter by category", {
        "Tasty coffee" => "coffee",
        "Exciting movies" => "movies"
      }
    end

Now you can display the grid by placing this line in your view:

    <%= render_grid @grid %>
