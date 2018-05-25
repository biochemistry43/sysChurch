class CategoriaMerma < ActiveRecord::Base
	has_many :mermas
    belongs_to :negocio

end
