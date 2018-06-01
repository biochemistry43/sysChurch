class CreateRegimenFiscals < ActiveRecord::Migration
  def change
    create_table :regimen_fiscals do |t|
      t.string :cve_regimen_fiscalSAT
      t.string :nomb_regimen_fiscalSAT
      t.boolean :personaFisica
      t.boolean :personaMoral

      t.timestamps null: false
    end
  end
end
