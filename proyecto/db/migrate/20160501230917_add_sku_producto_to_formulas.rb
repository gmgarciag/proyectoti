class AddSkuProductoToFormulas < ActiveRecord::Migration
  def change
    add_column :formulas, :skuProducto, :integer
  end
end
