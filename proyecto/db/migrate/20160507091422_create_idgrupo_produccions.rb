class CreateIdgrupoProduccions < ActiveRecord::Migration
  def change
    create_table :idgrupo_produccions do |t|

      t.timestamps null: false
    end
  end
end
