# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"

  # Funny thing here... This will include everything in a Wasify prepack, so need to exclude some things.
  t.test_files = FileList["test/**/test_*.rb"].exclude("test/cache/**/*")
end

task default: :test
