module LocatorsHelper
	def search(type, string)
  		Locator.where("#{type} like ?", '%' + string + '%')
  	end
end
