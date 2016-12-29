json.array!(@articulos) do |articulo|
  json.extract! articulo, :id, :clave, :nombre, :descripcion, :stock, :cat_articulo_id
  json.url articulo_url(articulo, format: :json)
end
