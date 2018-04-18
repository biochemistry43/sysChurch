class Cliente < ActiveRecord::Base
	has_many :facturas
	has_many :factura_recurrentes
	belongs_to :negocio
	has_one :datos_fiscales_cliente, dependent: :destroy
	has_many :ventas

	validates :nombre, :presence => { message: "Este campo no puede ir vacío" }

	def nombre_completo
      "#{nombre} #{ape_pat} #{ape_mat}"
	end

	def enviar_al_correo
		if email.present?
			"Enviar a: #{email}"
		else
			"Si desea enviar la factura debe registrar el correo del cliente!"
		end
	end

end
