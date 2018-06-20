class FacturasEmail < ApplicationMailer

  default from: "leinadlm95@gmail.com" #Cambiarlo por el correo del negocio

  def factura_email (destinatario, mensaje, tema, comprobantes)
    #Tengo pendiente comprobar que los archivos existan en la carpeta para evitar un error al intentar leer un archivo.***

    #Para enviar las facturas en formato xml y/o pdf
    attachments['RepresentaciónImpresa.pdf'] =  open( comprobantes.fetch(:pdf) ).read if comprobantes.key?(:pdf)
    attachments['CFDI.xml'] =  open( comprobantes.fetch(:xml) ).read if comprobantes.key?(:xml)
    #Una nota de crédito también se puede enviar en formato xml y/o pdf
    attachments['NotaCrédito.pdf'] =  open( comprobantes.fetch(:pdf_nc) ).read if comprobantes.key?(:pdf_nc)
    attachments['NotaCrédito.xml'] =  open( comprobantes.fetch(:xml_nc) ).read if comprobantes.key?(:xml_nc)
    #Cuando se cancela una factura se le debe de enviar el acuse de cancelación para que el usuario compruebe que anuló la factura relacionada.
    attachments['AcuseCancelación.xml'] =  open( comprobantes.fetch(:xml_Ac) ).read if comprobantes.key?(:xml_Ac)
    #Las notas de crédito también
    attachments['AcuseDeCancelaciónNotaCrédito.xml'] =  open( comprobantes.fetch(:xml_Ac_nc) ).read if comprobantes.key?(:xml_Ac_nc)

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
