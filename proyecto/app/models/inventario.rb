class Inventario < ActiveRecord::Base

  validates_uniqueness_of :sku
end
