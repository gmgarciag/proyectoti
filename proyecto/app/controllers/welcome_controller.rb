class WelcomeController < ApplicationController
require 'rest-client'
require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'
  def index
    comprar(7, 1)
  end
  def comprar(_sku,cantidad)

if _sku != nil
 
 grupoProveedor=(Proveedor.find_by skuProducto: _sku).grupoProveedor
 puts grupoProveedor
 #asumo que ya tengo plata
 #obtengo el ID del grupo
 idGrupo=(IdGrupo.find_by numeroGrupo: grupoProveedor).idGrupo

#llamada a crear la orden de compra, retorna la orden de compra o error
 @ordenCompra=RestClient.put 'http://mare.ing.puc.cl/oc/crear/', {:cliente => '571262b8a980ba030058ab4f', :proveedor => idGrupo, :sku => 47, :fechaEntrega => 1463797342000, :cantidad => 4, :precioUnitario => 7244, :canal => 'b2b'}.to_json, :content_type => 'application/json'

 end

end
end
