class CreateNuestroProductos < ActiveRecord::Migration
  def change
    create_table :nuestro_productos do |t|
      t.integer :sku
      t.string :descripcion
      t.integer :precio

      t.timestamps null: false
    end
  end
end
