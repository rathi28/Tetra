class Offerdatum < ActiveRecord::Base
  # maps to Offerdata table in database
  has_one :offer_data_detail, dependent: :destroy
  belongs_to :campaign

  # requires the OfferCode field to be present
  validates :OfferCode, presence: true


  # setup filter methods for sorting Offerdata information. shortcut to creating WHERE statements in controller
  scope :brand, -> (brand) { where brand: brand }
  scope :grcid, -> (grcid) { where grcid: grcid }
  scope :stg, -> (stg) { where stg: stg }
  scope :qa, -> (qa) { where qa: qa }
  scope :prod, -> (prod) { where prod: prod }
  scope :desktop, -> (desktop) { where desktop: desktop }
  scope :mobile, -> (mobile) { where mobile: mobile }
end