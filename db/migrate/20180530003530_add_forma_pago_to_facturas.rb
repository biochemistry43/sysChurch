class AddFormaPagoToFacturas < ActiveRecord::Migration
  def change
    add_reference :facturas, :factura_forma_pago, index: true, foreign_key: true
  end
end
