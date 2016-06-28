module Spree
  class HomeController < Spree::StoreController
    helper 'spree/products'
    respond_to :html

    def index

     # (Inventario.find_by sku:7).update(cantidadVendida:0)
     # (Inventario.find_by sku:19).update(cantidadVendida:0)
     # (Orden.find_by (sku:7, estado: 'LPD')).update(estado: 'rechazada')
      
      @searcher = build_searcher(params.merge(include_images: true))
      Product.first.update(name: 'Sémola')
      Product.second.update(name: 'Levadura')
      Product.third.update(name: 'Queso')
      Product.fourth.update(name: 'Celulosa')
      Product.fifth.update(name: 'Vino')
      Price.first.update(amount: 1613)
      Price.third.update(amount: 1376)
      Price.fifth.update(amount: 8744)
      Price.find(7).update(amount: 1695)
      Price.find(9).update(amount: 7244)
      semola = ((Inventario.find_by sku: 19).cantidadBodega).to_i - ((Inventario.find_by sku: 19).cantidadVendida).to_i
      levadura = ((Inventario.find_by sku: 27).cantidadBodega).to_i - ((Inventario.find_by sku: 27).cantidadVendida).to_i
      queso = ((Inventario.find_by sku: 40).cantidadBodega).to_i - ((Inventario.find_by sku: 40).cantidadVendida).to_i
      celulosa = ((Inventario.find_by sku: 45).cantidadBodega).to_i - ((Inventario.find_by sku: 45).cantidadVendida).to_i
      vino = ((Inventario.find_by sku: 47).cantidadBodega).to_i - ((Inventario.find_by sku: 47).cantidadVendida).to_i
      StockItem.find(1).update(count_on_hand:semola)
      StockItem.find(2).update(count_on_hand:levadura)
      StockItem.find(3).update(count_on_hand:queso)
      StockItem.find(4).update(count_on_hand:celulosa)
      StockItem.find(5).update(count_on_hand:vino)
      Property.create(name:'Stock', presentation:'Stock')
      i = (ProductProperty.order(id: :asc)).first.id
      j = (ProductProperty.order(id: :asc)).last.id
      puts 'i = ' + i.to_s
      puts 'j = ' + j.to_s
      until i > j do
        begin
        ProductProperty.find(i).destroy
        rescue
        end
        i += 1
        puts i
      end
      ProductProperty.create(value:semola, product_id:1, property_id:12, position:1)
      ProductProperty.create(value:levadura, product_id:2, property_id:12, position:1)
      ProductProperty.create(value:queso, product_id:3, property_id:12, position:1)
      ProductProperty.create(value:celulosa, product_id:4, property_id:12, position:1)
      ProductProperty.create(value:vino, product_id:5, property_id:12, position:1)
      i = 6
      j = Product.last.id
      until i > j do
        Product.find(i).destroy
        i += 1
      end
      (Variant.where(is_master: false)).find_each do |variant|
        Variant.find(variant.id).destroy
      end
      #product = Spree::Product.last
      #Spree::Image.create!(:attachment => File.open('levadura.png'), :viewable_id => product.id, :viewable => product)
      @products = @searcher.retrieve_products
      @taxonomies = Spree::Taxonomy.includes(root: :children)
    end
  end
end
