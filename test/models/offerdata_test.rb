require 'test_helper'
require 'pry'

class OfferdataTest < ActiveSupport::TestCase
	test "Offerdata can be requested" do	
			offer = Offerdatum.new(OfferCode: "Fake34")
			offer.save!
		assert_not_nil Offerdatum.all().first()
	end

	test "OfferCode required for valid offer insert" do
		assert_raises ActiveRecord::RecordInvalid do
			offer = Offerdatum.new()
			offer.save!
		end
	end

	test "Can create entry" do
		offer = Offerdatum.new(OfferCode: "Fake34")
		offer.save!
		assert Offerdatum.where(OfferCode: "Fake34")
	end

	test "Can delete entry" do
		offer = Offerdatum.new(OfferCode: "Fake34")
		offer.save!
		Offerdatum.where(OfferCode: "Fake34").first.destroy!
		assert_nil Offerdatum.where(OfferCode: "Fake34").first()
	end
end