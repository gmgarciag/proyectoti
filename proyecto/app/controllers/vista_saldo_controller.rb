class VistaSaldoController < ApplicationController

def index

valores = []
dia = []
i=0
Saldo.all.each do |s|
valores.insert(i,s.saldo.to_i)
dia.insert(i,s.id)
i=i+1
puts s.id
end

 @graficoSaldo = Gchart.line(:size => '500x500', :theme => :keynote, :title => "Saldo", :bg => 'efefef', :axis_with_labels => 'x,y', :data => [valores] , :axis_range => [[1,dia.last,1],[valores.min,valores.max,(valores.max-valores.min)/10]], :min_y_value => valores.min, :min_x_value => 1)
end

def cartola 
@ids = []
@fechas = []
@montos = []
@destinos = []
date = params[:fecha].to_i
puts date

pedidos = RestClient.post  'http://moto.ing.puc.cl/banco/cartola/',
 {:fechaInicio => date, :fechaFin => (date+86400000), :id => '572aac69bdb6d403005fb04e'}.to_json, :content_type => 'application/json'

=begin
pedidos = RestClient.post  'http://moto.ing.puc.cl/banco/cartola/',
 {:fechaInicio => 1463705467000, :fechaFin => 1464396667000, :id => '571262c3a980ba030058ab5b'}.to_json, :content_type => 'application/json'
=end
pedidos2 = JSON.parse pedidos 
pedidosParseado=pedidos2['data']
puts pedidosParseado
i=0
while i<pedidosParseado.length do
	@ids.insert(i,pedidosParseado[i]['_id'])
	@fechas.insert(i,pedidosParseado[i]['created_at'])
	@montos.insert(i,pedidosParseado[i]['monto'])
	@destinos.insert(i,pedidosParseado[i]['destino'])
	i=i+1
	end

end

end