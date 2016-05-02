class CreatePedidos < ActiveRecord::Migration
  def change
    create_table :pedidos do |t|
      t.string :idPedido
      t.datetime :creacion
      t.string :proveedor
      t.integer :cantidad
      t.integer :despachado
      t.integer :fechaEntrega
      t.string :estado
      t.boolean :transaccion

      t.timestamps null: false
    end
  end
end
