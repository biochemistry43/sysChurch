json.array!(@facturas) do |factura|
  json.extract! factura, :id, :folio, :fecha_expedicion, :estado_factura, :venta_id, :user_id, :negocio_id, :sucursal_id, :cliente_id, :forma_pago_id
  json.url factura_url(factura, format: :json)
end
