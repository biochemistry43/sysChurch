class Cliente < ActiveRecord::Base
	belongs_to :negocio
	has_one :datos_fiscales_cliente
	has_many :ventas

	validates :nombre, :presence => { message: "Este campo no puede ir vacío" }
end
