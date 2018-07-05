class CreatePlantillasEmails < ActiveRecord::Migration
  def change
    create_table :plantillas_emails do |t|
      t.string :asunto_email
      t.text :msg_email
      t.string :comprobante
      t.references :negocio, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
