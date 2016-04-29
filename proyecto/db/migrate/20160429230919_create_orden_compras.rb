class CreateOrdenCompras < ActiveRecord::Migration
  def change
    create_table :orden_compras do |t|
      t.string :idOC
      t.integer :sku
      t.integer :cantidad

      t.timestamps null: false
    end
  end
end
