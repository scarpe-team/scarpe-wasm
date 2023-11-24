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

  # We can't easily return Ruby objects or even data from Ruby eval calls. So for queries
  # like button() we create a JS-side proxy object with an ID we got from host-side
  # Ruby. Then when it makes other calls (e.g. button.text) on that proxy, we know
  # what in-browser Ruby object is being called.
  #
  # @return [void]
  def create_query_proxy(id, drawable_type, query_by)
    d_class = Shoes::Drawable.drawable_class_by_name(drawable_type)
    drawables = Shoes::App.instance.find_drawables_by(d_class, *query_by)
    raise Shoes::Errors::MultipleDrawablesFoundError, "Found more than one #{drawable_type} matching #{query_by.inspect}!" if drawables.size > 1
    raise Shoes::Errors::NoDrawablesFoundError, "Found no #{drawable_type} matching #{query_by.inspect}!" if drawables.empty?
    drawable = drawables[0]

    @query_proxies[id] = drawable
    nil
  end

  # Call a method on a proxy by proxy ID
  def proxy_method(id, method_name, args)
    p = @query_proxies[id]
    val = p.send(method_name, *args)

    # By default, return values are going to get treated as Strings.
    # That's not useful for Drawables (or many other types.)
    if val.is_a?(Shoes::Drawable)
      return ["shoes_obj", val.class.dsl_name, val.linkable_id]
    end

    ["value", val]
  end

  # Trigger a JS event for the specified proxy drawable and event name
  def proxy_trigger(id, event, args)
    p = @query_proxies[id]
    cb_name = "#{p.linkable_id}-#{event}"
    Scarpe::Wasm::DisplayService.instance.app.handle_callback(cb_name, *args)
  end
end
