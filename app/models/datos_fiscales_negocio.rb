class DatosFiscalesNegocio < ActiveRecord::Base
	belongs_to :negocio
	belongs_to :regimen_fiscal

	#validates :nombreFiscal, :rfc, :calle, :numExterior, :numInterior, :colonia, :codigo_postal, :municipio, :delegacion, :estado, :email, :presence => { message: "Campo obligatorio"}
end
