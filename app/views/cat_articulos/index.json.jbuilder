json.array!(@cat_articulos) do |cat_articulo|
  json.extract! cat_articulo, :id, :nombreCatArticulo, :descripcionCatArticulo, :idCategoriaPadre
  json.url cat_articulo_url(cat_articulo, format: :json)
end
