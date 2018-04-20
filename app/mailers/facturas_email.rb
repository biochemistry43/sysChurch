class FacturasEmail < ApplicationMailer
  default from: "leinadlm95@gmail.com" #Cambiarlo por el correo del negocio

  def factura_email (destinatario, mensaje, tema)
     @destinatario = destinatario#params[:user]
     @mensaje = mensaje#params[:mensaje]
     @tema = tema#params[:tema]

     mail(to: @destinatario,
          body: @mensaje,
          content_type: "text/html",
          subject: @tema)
   end
end
