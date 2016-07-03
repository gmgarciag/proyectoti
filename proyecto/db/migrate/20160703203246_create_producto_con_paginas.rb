class CreateProductoConPaginas < ActiveRecord::Migration
  def change
    create_table :producto_con_paginas do |t|
    	t.string :sku
    	t.string :nombre
    	t.string :enlace
      t.timestamps null: false
    end
  end
end
