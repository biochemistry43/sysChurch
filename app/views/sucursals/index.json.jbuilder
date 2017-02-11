json.array!(@sucursals) do |sucursal|
  json.extract! sucursal, :id, :nombre, :representante, :direccion, :negocio_id
  json.url sucursal_url(sucursal, format: :json)
end
