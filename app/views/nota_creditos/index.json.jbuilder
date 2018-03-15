json.array!(@nota_creditos) do |nota_credito|
  json.extract! nota_credito, :id, :folio, :fecha_expedicion, :monto_devolucion, :motivo, :user_id, :cliente_id, :sucursal_id, :negocio_id
  json.url nota_credito_url(nota_credito, format: :json)
end
