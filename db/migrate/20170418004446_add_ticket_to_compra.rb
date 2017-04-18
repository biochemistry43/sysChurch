class AddTicketToCompra < ActiveRecord::Migration
  def change
    add_column :compras, :ticket_compra, :string
  end
end
