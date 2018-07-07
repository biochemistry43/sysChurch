class AddComprobanteToConfigComprobantes < ActiveRecord::Migration
  def change
    add_column :config_comprobantes, :comprobante, :string
  end
end
