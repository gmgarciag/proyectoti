class CompraMateriaController < ApplicationController

def comprar(_sku,cantidad)

if sku != nil
	
	a=Proveedor.find_by skuProducto: _sku
	puts a


end

end
end
