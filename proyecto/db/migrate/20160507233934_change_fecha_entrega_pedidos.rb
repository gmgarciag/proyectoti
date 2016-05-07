class ChangeFechaEntregaPedidos < ActiveRecord::Migration
  def up
    change_column :pedidos, :fechaEntrega, :datetime
  end

  def down
    change_column :pedidos, :fechaEntrega, :integer
  end

end
