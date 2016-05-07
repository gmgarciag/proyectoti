class Pedido < ActiveRecord::Base
	validates_uniqueness_of :idPedido
end
