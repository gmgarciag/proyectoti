class CreateIdGrupos < ActiveRecord::Migration
  def change
    create_table :id_grupos do |t|

    	t.integer :numeroGrupo
    	t.string :idGrupo
    	t.string :idBanco
    	t.string :idBodegaRecepcion

      t.timestamps null: false
    end
  end
end
