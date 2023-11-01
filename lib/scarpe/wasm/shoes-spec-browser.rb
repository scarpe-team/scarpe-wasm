# frozen_string_literal: true

# This file is require-able on the browser, running in Wasm.
# It will normally only be required when test code is running.

# This test object can query objects and otherwise perform Ruby code
# via Capybara on behalf of the Capybara tests.
class ShoesSpecBrowser
  def self.instance
    @instance ||= ShoesSpecBrowser.new
  end

  def initialize
    find_all_drawable_ids
  end

  def drawable_by_id(id)
    drawable = @drawable_by_id[id]
    if drawable.destroyed
      # Looks deleted
      drawable = nil
    end

    if !drawable
      find_all_drawable_ids
      drawable = @drawable_by_id[id] # Could still be nil, but this should be fully up to date
    end

    drawable
  end

  private

  def find_all_drawable_ids
    @drawable_by_id = {}
    root = Shoes::App.instance.find_drawables_by("DocumentRoot")
    drawables = [root]
    until drawables.empty?
      first = drawables.pop
      @drawable_by_id[first.shoes_linkable_id] = first
      if first.respond_to?(:children)
        drawables.concat first.children
      end
    end
  end

  public

  def query_drawable_id(drawable_type, *specs)
    app = Shoes::App.instance

    drawables = app.find_drawables_by(drawable_type, *specs)
    raise Scarpe::MultipleDrawablesFoundError, "Found more than one #{finder_name} matching #{args.inspect}!" if drawables.size > 1
    raise Scarpe::NoDrawablesFoundError, "Found no #{finder_name} matching #{args.inspect}!" if drawables.empty?

    drawables[0].linkable_id
  end
end
