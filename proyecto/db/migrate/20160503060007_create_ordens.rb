class CreateOrdens < ActiveRecord::Migration
  def change
    create_table :ordens do |t|
      t.string :idOrden
      t.datetime :fechaCreacion
      t.string :canal
      t.string :cliente
      t.string :sku
      t.string :cantidad
      t.string :despachada
      t.integer :precioUnitario
      t.datetime :fechaEntrega
      t.string :estado
      t.string :rechazo
      t.string :anulacion
      t.string :idFactura

      t.timestamps null: false
    end
  end
end
