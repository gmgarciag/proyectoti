class CreateFacturas < ActiveRecord::Migration
  def change
    create_table :facturas do |t|
      t.string :string
      t.string :creado
      t.string :string
      t.string :clinte
      t.string :string
      t.string :proveedor
      t.string :int
      t.string :total
      t.string :string
      t.string :idFactura
      t.string :string
      t.string :estado

      t.timestamps null: false
    end
  end
end
