class CreateStockDiarios < ActiveRecord::Migration
  def change
    create_table :stock_diarios do |t|
      t.integer :sku
      t.integer :cantidad
      t.datetime :fecha

      t.timestamps null: false
    end
  end
end
