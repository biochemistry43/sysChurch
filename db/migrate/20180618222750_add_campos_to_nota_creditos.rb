class AddCamposToNotaCreditos < ActiveRecord::Migration
  def change
    add_reference :nota_creditos, :factura, index: true, foreign_key: true
    add_column :nota_creditos, :estado_nc, :string
    add_column :nota_creditos, :ruta_storage, :string
    add_column :nota_creditos, :consecutivo, :integer
    add_column :nota_creditos, :folio_fiscal, :string
    add_column :nota_creditos, :monto, :decimal
    add_reference :nota_creditos, :factura_forma_pago, index: true, foreign_key: true
  end
end
