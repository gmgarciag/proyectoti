class CreateInventarios < ActiveRecord::Migration
  def change
    create_table :inventarios do |t|
      t.string :sku
      t.string :cantidadBodega
      t.string :cantidadVendida

      t.timestamps null: false
    end
  end
end
