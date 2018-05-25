class Merma < ActiveRecord::Base
	belongs_to :categoria_merma
	belongs_to :articulo
	belongs_to :user
	belongs_to :sucursal
	belongs_to :negocio
end
