json.array!(@gasto_generals) do |gasto_general|
  json.extract! gasto_general, :id, :folio_gasto, :ticket_gasto, :monto, :concepto, :gasto_id, :user_id, :sucursal_id, :negocio_id
  json.url gasto_general_url(gasto_general, format: :json)
end
