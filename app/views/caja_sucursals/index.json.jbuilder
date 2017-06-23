json.array!(@caja_sucursals) do |caja_sucursal|
  json.extract! caja_sucursal, :id, :numero_caja, :nombre, :sucursal_id
  json.url caja_sucursal_url(caja_sucursal, format: :json)
end
