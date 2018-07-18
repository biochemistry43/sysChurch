json.array!(@factura_globals) do |factura_global|
  json.extract! factura_global, :id, :folio, :fecha_expedicion, :estado_factura, :user_id, :negocio_id, :sucursal_id, :folio_fiscal, :consecutivo, :ruta_storage, :factura_forma_pago_id, :monto
  json.url factura_global_url(factura_global, format: :json)
end
