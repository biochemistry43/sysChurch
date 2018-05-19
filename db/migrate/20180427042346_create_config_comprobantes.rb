class CreateConfigComprobantes < ActiveRecord::Migration
  def change
    create_table :config_comprobantes do |t|
      t.string :asunto_email
      t.string :msg_email
      t.string :tipo_fuente
      t.string :tam_fuente
      t.string :color_fondo
      t.string :color_titulos
      t.string :color_banda
      t.references :negocio, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
