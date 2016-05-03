class CreateXmls < ActiveRecord::Migration
  def change
    create_table :xmls do |t|

    	t.string :nombreArchivo
    	
      t.timestamps null: false
    end
  end
end
