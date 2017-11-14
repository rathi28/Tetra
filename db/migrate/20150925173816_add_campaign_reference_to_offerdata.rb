class AddCampaignReferenceToOfferdata < ActiveRecord::Migration
  def change
    add_reference :offerdata, :campaign, index: true
  end
end
