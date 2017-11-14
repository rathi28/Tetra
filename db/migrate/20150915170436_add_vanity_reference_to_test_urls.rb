class AddVanityReferenceToTestUrls < ActiveRecord::Migration
  def change
    add_reference :test_urls, :vanity_uci_suite, index: true
  end
end
