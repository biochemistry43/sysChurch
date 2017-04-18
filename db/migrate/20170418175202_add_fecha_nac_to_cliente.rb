class AddFechaNacToCliente < ActiveRecord::Migration
  def change
    add_column :clientes, :fecha_nac, :date
  end
end
