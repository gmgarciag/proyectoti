class AddSkuProductoToProveedors < ActiveRecord::Migration
  def change
    add_column :proveedors, :skuProducto, :integer
  end
end
