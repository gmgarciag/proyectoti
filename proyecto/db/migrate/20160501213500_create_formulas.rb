class CreateFormulas < ActiveRecord::Migration
  def change
    create_table :formulas do |t|
    	t.string :productoProducir
    	t.string :insumo
    	t.integer :cantidadRequerida
    	t.integer :loteProducido
    	t.integer :skuInsumo
    	t.integer :skuProducto


      t.timestamps null: false
    end
  end
end
