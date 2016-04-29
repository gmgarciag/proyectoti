class ApiController < ApplicationController
require 'json'
require 'rest-client'
require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'
  def consultar
  	key = 'W0B@c0w9.xqo1nQ'
  	hmac = HMAC::SHA1.new(key)
    hmac.update(signature)
    clave = Base64.encode64("#{hmac.digest}")
  	almacenes = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/almacenes', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'}
  	




  	if params[:sku]
  	end

  	# retorna un json con la informacion
	render json: {
		cantidad: 2,
		sku: params[:sku]
	}


  end
end