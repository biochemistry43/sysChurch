json.array!(@plantillas_emails) do |plantillas_email|
  json.extract! plantillas_email, :id, :asunto_email, :msg_email, :comprobante, :negocio_id
  json.url plantillas_email_url(plantillas_email, format: :json)
end
