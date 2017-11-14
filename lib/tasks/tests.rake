require 'ci/reporter/rake/minitest'

namespace :test do
  desc "Test tests/grotto/* code"
  Rails::TestTask.new(grotto: 'test:prepare') do |t|
    t.pattern = 'test/grotto/**/*_test.rb'
  end

  desc "Test tests/thirdparty/* code"
  Rails::TestTask.new(thirdparty: 'test:prepare') do |t|
    t.pattern = 'test/thirdparty/**/*_test.rb'
  end

  desc "Test tests/email/* code"
  Rails::TestTask.new(email: 'test:prepare') do |t|
    t.pattern = 'test/email/**/*_test.rb'
  end

  desc "Test tests/vanityprod/* code"
  Rails::TestTask.new(vanityprod: 'test:prepare') do |t|
    t.pattern = 'test/ci/vanityprod/*_test.rb'
  end
  
  ## Duplicate this section of code for a new build configuration
  desc "Test tests/r1_all_brands_prod/* code"
  Rails::TestTask.new(r1_all_brands_prod: 'test:prepare') do |t|
    t.pattern = 'test/ci/**/r1_all_brands_prod.rb'
  end
  ###
end

# each suite should have a task

# Realm 1 - all brands - QA/STG
task 'test:r1_all_brands_prod' => 'ci:setup:minitest'

task 'test:vanityprod' => 'ci:setup:minitest'