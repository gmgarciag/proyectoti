require 'bunny'
require 'json'
require 'koala'
require 'twitter'
require 'date'
require 'cgi'

namespace :requestsOfertas do

desc "TODO"
  task revisarOfertas: :environment do
    puts "Comenzo a revisar ofertas #{Time.now}"




    b = Bunny.new elLink ## Para conectarse a nuestra sesion
      b.start ## Para iniciar comunicacion
      ch = b.create_channel
      q = ch.queue(laCola)
      cuenta = q.message_count
      puts 'la cola tiene '+ cuenta.to_s + ' mensajes'
      if (cuenta>0)
        while (cuenta > 0) do
          delivery_info, properties, payload = q.pop
        puts 'entre al subscribe'
        hashRespuesta = JSON.parse(payload)
        puts hashRespuesta
        ## Hay que guardar en la base de datos la informacion, para que las ofertas calcen:
        
        if(hashRespuesta['publicar'] == true)
          puts hashRespuesta
          puts 'entro'
          seCayo = false
          begin
            sku = (hashRespuesta['sku']).to_s
            nombreProducto = (ProductoConPagina.find_by sku: sku).nombre #hashRespuesta['sku']
            enlaceProducto = (ProductoConPagina.find_by sku: sku).enlace
          rescue
            puts 'se cayo en la busqueda en ProductoConPagina'
            seCayo = true
          end
          puts 'siguio'
          if (seCayo == false)
            begin
              ##################################################################################
                ##############################TWITTER############################
              ##################################################################################
               @client = Twitter::REST::Client.new do |config|




              end
              mensaje = 'Oferta! '+nombreProducto +' a solo '+(hashRespuesta['precio']).to_s +
                    ' con el codigo '+ (hashRespuesta['codigo']) + ' hasta '+ (Time.at(hashRespuesta['fin']).to_datetime).to_s 
                @client.update_with_media(mensaje , open(enlaceProducto))
                puts 'publico Twitter'
            rescue
              puts 'Se cayo en Twitter'
            end
            ##################################################################################
            ##############################FACEBOOK############################
            ##################################################################################
            begin

              @page_graph.get_object('me') # I'm a page
              @page_graph.get_connection('me', 'feed') # the page's wall
              #@page_graph.put_wall_post('Oferta el producto '+(hashRespuesta['sku'])+' a un precio de '+(hashRespuesta['precio']).to_s+
              #         'con el codigo '+ (hashRespuesta['codigo']) + 'desde el dia '+ (hashRespuesta['inicio']).to_s +
              #         ' hasta el dia '+ (hashRespuesta['fin']).to_s ) 
              #@page_graph.put_connections(894241084038304, 'feed', :message => message, :picture => picture_url, :link => link_url) 
                @page_graph.put_connections(894241084038304, 'feed', :message => mensaje , :picture => enlaceProducto , :link => enlaceProducto) 
                puts 'publico Facebook'
            rescue
              puts 'Se cayo en Facebook'
            end
          end
        else
          puts 'no se debia publicar'
        end
        cuenta = q.message_count
      end
    else
      puts 'no habian mensajes!'
    end
      b.close
  end
end