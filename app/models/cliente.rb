class Cliente < ActiveRecord::Base
	belongs_to :negocio
	has_one :datos_fiscales_cliente
	has_many :ventas

	validates :nombre, :ape_pat, :ape_mat, :presence => { message: "Este campo no puede ir vacío" }

	def nombre_completo
      "#{nombre} #{ape_pat} #{ape_mat}"
	end
end
