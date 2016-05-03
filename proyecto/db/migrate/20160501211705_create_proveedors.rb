class CreateProveedors < ActiveRecord::Migration
  def change
    create_table :proveedors do |t|
    	t.string :materiaPrima
    	t.integer :skuMateriaPrima
    	t.integer :skuProducto
    	t.string :productoProcesar
    	t.integer :grupoProveedor
    	t.integer :cantidadRequerida
    	t.integer :precio

      t.timestamps null: false
    end
  end
end
