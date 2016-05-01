class CreateProductos < ActiveRecord::Migration
  def change
    create_table :productos do |t|
      t.string :id
      t.string :sku
      t.string :almacenId
      t.double :costos

      t.timestamps null: false
    end
  end
end
