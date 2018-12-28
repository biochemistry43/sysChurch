class DatosFiscalesClientesController < ApplicationController
	def obtener_datos_fiscales
		render :json => DatosFiscalesCliente.where(cliente_id: current_user.negocio.clientes).order(:nombreFiscal)
	end
end
