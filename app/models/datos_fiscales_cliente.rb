class DatosFiscalesCliente < ActiveRecord::Base
	belongs_to :cliente

	validates :nombreFiscal, :rfc, :calle, :numExterior, :numInterior, :colonia, :codigo_postal, :municipio, :delegacion, :estado, :email, :presence => { message: "Campo obligatorio"}
end
