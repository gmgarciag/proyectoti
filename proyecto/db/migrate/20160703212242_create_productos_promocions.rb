class CreateProductosPromocions < ActiveRecord::Migration
  def change
    create_table :productos_promocions do |t|
      t.string :string
      t.string :sku
      t.string :integer
      t.string :precio
      t.string :string
      t.string :codigo
      t.string :integer
      t.string :inicio
      t.string :integer
      t.string :fin

      t.timestamps null: false
    end
  end
end
