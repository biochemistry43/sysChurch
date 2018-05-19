json.array!(@impuestos) do |impuesto|
  json.extract! impuesto, :id, :nombre, :tipo, :porcentaje, :descripcion
  json.url impuesto_url(impuesto, format: :json)
end
