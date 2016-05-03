class AddSkuInsumoToFormulas < ActiveRecord::Migration
  def change
    add_column :formulas, :skuInsumo, :integer
  end
end
