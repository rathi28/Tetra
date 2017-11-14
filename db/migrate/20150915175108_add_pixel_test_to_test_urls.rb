class AddPixelTestToTestUrls < ActiveRecord::Migration
  def change
    add_reference :test_urls, :pixel_test, index: true
  end
end
