class CreateCostoProduccions < ActiveRecord::Migration
  def change
    create_table :costo_produccions do |t|
    	t.integer :skuProducto
    	t.string :nombreProducto
    	t.string :tipoProducto
    	t.integer :costoProdUnitario
    	t.integer :loteProduccion
    	t.decimal :tiempoMedio

      t.timestamps null: false
    end
  end
end
