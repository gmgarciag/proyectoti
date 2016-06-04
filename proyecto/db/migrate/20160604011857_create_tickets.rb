class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :string
      t.string :idBoleta
      t.string :string
      t.string :direccion
      t.string :int
      t.string :sku
      t.string :int
      t.string :cantidad
      t.string :int
      t.string :iva
      t.string :int
      t.string :bruto
      t.string :int
      t.string :total

      t.timestamps null: false
    end
  end
end
