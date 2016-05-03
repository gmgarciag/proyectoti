class AddSkuMateriaPrimaToProveedors < ActiveRecord::Migration
  def change
    add_column :proveedors, :skuMateriaPrima, :integer
  end
end
