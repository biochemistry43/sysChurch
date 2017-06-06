class AddObservacionesToCompra < ActiveRecord::Migration
  def change
    add_column :compras, :observaciones, :string
  end
end
