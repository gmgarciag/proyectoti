class CreateAlmacens < ActiveRecord::Migration
  def change
    create_table :almacens do |t|
      t.string :almacenId
      t.integer :espacioUtilizado
      t.integer :espacioTotal
      t.boolean :recepcion
      t.boolean :depacho
      t.boolean :pulmon

      t.timestamps null: false
    end
  end
end
