json.array!(@config_comprobantes) do |config_comprobante|
  json.extract! config_comprobante, :id, :tipo_comprobante, :asunto_email, :msg_email, :tipo_fuente, :tam_fuente, :color_fondo, :color_titulos, :color_banda, :negocio_id
  json.url config_comprobante_url(config_comprobante, format: :json)
end
