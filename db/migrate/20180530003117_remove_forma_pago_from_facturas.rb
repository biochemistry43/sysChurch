class RemoveFormaPagoFromFacturas < ActiveRecord::Migration
  def change
    remove_reference :facturas, :forma_pago, index: true, foreign_key: true
  end
end
