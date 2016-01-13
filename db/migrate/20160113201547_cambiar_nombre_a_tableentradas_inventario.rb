class CambiarNombreATableentradasInventario < ActiveRecord::Migration
  def change
  	rename_table :entradasInventario, :entradasinventario
  end
end
