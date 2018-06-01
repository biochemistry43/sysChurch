class RegimenFiscal < ActiveRecord::Base
  has_one :datos_fiscales_negocio
  def cve_nombre_regimen_fiscalSAT
      "#{cve_regimen_fiscalSAT} - #{nomb_regimen_fiscalSAT}"
  end
end
