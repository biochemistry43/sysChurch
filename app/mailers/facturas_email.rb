class FacturasEmail < ApplicationMailer

  default from: "leinadlm95@gmail.com" #Cambiarlo por el correo del negocio

  def factura_email (destinatario, mensaje, tema)

    attachments['IMG_20171225_243621204.jpg'] =  open('public/IMG_20171225_243621204.jpg').read

=begin
  mail(headers = {}, &block) public
  :subject - The subject of the message, if this is omitted, Action Mailer will ask the Rails I18n class for a translated :subject in the scope of [mailer_scope, action_name] or if this is missing, will translate the humanized version of the action_name
  :to - Who the message is destined for, can be a string of addresses, or an array of addresses.
  :from - Who the message is from
  :cc - Who you would like to Carbon-Copy on this email, can be a string of addresses, or an array of addresses.
  :bcc - Who you would like to Blind-Carbon-Copy on this email, can be a string of addresses, or an array of addresses.
  :reply_to - Who to set the Reply-To header of the email to.
  :date - The date to say the email was sent on.
=end

    #Tan simple :( como responder en formato html para que muestre el texto con sus estilos y no como texto plano.
    mail(to: destinatario, body:mensaje,  subject: tema) do |format|
      #format.text { render plain: "Hello Mikel!" }
      format.html { render html: "#{mensaje}".html_safe }
    end
    #fix_mixed_attachments
  end
end
