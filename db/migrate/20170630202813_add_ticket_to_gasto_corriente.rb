class AddTicketToGastoCorriente < ActiveRecord::Migration
  def change
    add_column :gasto_corrientes, :ticket_gasto, :string
  end
end
