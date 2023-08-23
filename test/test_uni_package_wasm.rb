# frozen_string_literal: true

require "test_helper"

# We can build a single package with all the gems needed, then
# load various Shoes apps and run them, as long as they don't
# need any gems *not* in the package.

class Scarpe::TestUnifiedPackageWasm < WasmPackageTestCase
  #def setup
  #end

  def test_app_runs
    with_app("button_alert") do
      assert_selector("button")
    end
  end

  def test_button_creates_alert
    with_app("button_alert") do
      assert_selector("button")
      assert_no_text("Aha!")
      click_button("Push me")
      assert_text("Aha!")

      #STDERR.puts "PAGE:\n#{page.html}"
    end
  end
end
