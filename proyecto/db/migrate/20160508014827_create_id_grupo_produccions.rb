class CreateIdGrupoProduccions < ActiveRecord::Migration
  def change
    create_table :id_grupo_produccions do |t|
      t.integer :numeroGrupo
      t.string :idGrupo
      t.string :idBanco
      t.string :idBodegaRecepcion

      t.timestamps null: false
    end
  end
end
