json.array!(@factura_recurrentes) do |factura_recurrente|
  json.extract! factura_recurrente, :id, :folio, :fecha_expedicion, :estado_factura, :tiempo_recurrente, :user_id, :negocio_id, :sucursal_id, :cliente_id, :forma_pago_id
  json.url factura_recurrente_url(factura_recurrente, format: :json)
end
