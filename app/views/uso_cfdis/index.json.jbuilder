json.array!(@uso_cfdis) do |uso_cfdi|
  json.extract! uso_cfdi, :id, :clave, :descripcion
  json.url uso_cfdi_url(uso_cfdi, format: :json)
end
