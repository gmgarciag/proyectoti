class CreateOrdenCompras < ActiveRecord::Migration
  def change
    create_table :orden_compras do |t|
      t.string :id
      t.datetime :creacion
      t.string :cliente
      t.string :sku
      t.integer :cantidad
      t.integer :despachado
      t.integer :fechaEntrega
      t.string :estado
      t.boolean :transaccion

      t.timestamps null: false
    end
  end
end
