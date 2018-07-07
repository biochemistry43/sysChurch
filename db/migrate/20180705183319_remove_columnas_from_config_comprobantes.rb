class RemoveColumnasFromConfigComprobantes < ActiveRecord::Migration
  def change
    remove_column :config_comprobantes, :asunto_email, :string
    remove_column :config_comprobantes, :msg_email, :text
  end
end
