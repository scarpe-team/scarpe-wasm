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
    @query_proxies = {}
  end

  #def drawable_by_id(id)
  #  drawable = @drawable_by_id[id]
  #  if drawable.destroyed
  #    # Looks deleted
  #    drawable = nil
  #  end
  #
  #  if !drawable
  #    find_all_drawable_ids
  #    drawable = @drawable_by_id[id] # Could still be nil, but this should be fully up to date
  #  end
  #
  #  drawable
  #end

  private

  #def find_all_drawable_ids
  #  @drawable_by_id = {}
  #  root = Shoes::App.instance.find_drawables_by("DocumentRoot")
  #  drawables = [root[0]]
  #  until drawables.empty?
  #    first = drawables.pop
  #    @drawable_by_id[first.linkable_id] = first
  #    if first.respond_to?(:children)
  #      drawables += first.children
  #    end
  #  end
  #end

  public

  # We can't easily return Ruby objects or even data from Ruby eval calls. So for queries
  # like button() we create a JS-side proxy object with an ID we got from host-side
  # Ruby. Then when it makes other calls (e.g. button.text) on that proxy, we know
  # what in-browser Ruby object is being called.
  #
  # @return [void]
  def create_query_proxy(id, drawable_type, query_by)
    d_class = Shoes::Drawable.drawable_class_by_name(drawable_type)
    drawables = Shoes::App.instance.find_drawables_by(d_class, *query_by)
    raise Scarpe::MultipleDrawablesFoundError, "Found more than one #{drawable_type} matching #{query_by.inspect}!" if drawables.size > 1
    raise Scarpe::NoDrawablesFoundError, "Found no #{drawable_type} matching #{query_by.inspect}!" if drawables.empty?
    drawable = drawables[0]

    @query_proxies[id] = drawable
    nil
  end

  # Call a method on a proxy by proxy ID
  def proxy_method(id, method_name, args)
    p = @query_proxies[id]
    p.send(method_name, *args)
  end

  # Trigger a JS event for the specified proxy drawable and event name
  def proxy_trigger(id, event, args)
    p = @query_proxies[id]
    cb_name = "#{p.linkable_id}-#{event}"
    Scarpe::Wasm::DisplayService.instance.app.handle_callback(cb_name, *args)
  end
end
