class OrdenCompra < ActiveRecord::Base

	validates_uniqueness_of :idOC
end
