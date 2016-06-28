class CreateSaldos < ActiveRecord::Migration
  def change
    create_table :saldos do |t|

      t.timestamps null: true
      t.integer :saldo
      t.float :fechaInicio
      t.float :fechaFin

    end
  end
end
