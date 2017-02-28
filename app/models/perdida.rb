class Perdida < ActiveRecord::Base
	belongs_to :cat_articulo
	belongs_to :categoria_perdida
	belongs_to :sucursal
end
