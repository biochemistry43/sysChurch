class AddTipoFacturaToNotaCreditos < ActiveRecord::Migration
  def change
    add_column :nota_creditos, :tipo_factura, :string
  end
end
