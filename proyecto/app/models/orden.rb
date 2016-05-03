class Orden < ActiveRecord::Base

validates_uniqueness_of :idOrden
end
