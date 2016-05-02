class CreateProductos < ActiveRecord::Migration
  def change
    create_table :productos do |t|
      t.string :idProducto
      t.string :sku
      t.string :almacenId
      t.decimal :costos

      t.timestamps null: false
    end
  end
end
