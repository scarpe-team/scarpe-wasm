# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in scarpe-folio.gemspec
gemspec

gem "scarpe-components", github: "scarpe-team/scarpe", glob: "scarpe-components/*.gemspec"
gem "lacci", github: "scarpe-team/scarpe", glob: "lacci/*.gemspec"

gem "wasify", github: "AlawysDelta/wasify"

gem "webrick"

group :development do
  gem "rake", "~> 13.0"
  gem "minitest", "~> 5.0"
  gem "capybara"
  gem "selenium-webdriver"
end
