#class Brand < ActiveRecord::Base
#end
class Brand < ActiveRecord::Base
  # maps to Brands table in database
    validates :Brandname, presence: true
    validates :Brandname, uniqueness: { case_sensitive: false }
end