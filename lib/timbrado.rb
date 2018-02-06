require 'base64'
#equire 'savon'
require 'nokogiri'
require 'byebug'

def generar_sello(comprobante, path_llave, password_llave)
  comprobante = Nokogiri::XML(comprobante)
  comprobante = actualizar_fecha(comprobante)
  cadena = get_cadena_original(comprobante)

  #Generar digestion y sello
  private_key = OpenSSL::PKey::RSA.new(File.read(path_llave), password_llave)
  digester = OpenSSL::Digest::SHA256.new
  signature = private_key.sign(digester, cadena)
  sello = Base64.strict_encode64(signature)
  comprobante = actualizar_sello(comprobante, sello)
end

#Obtener cadena original
def get_cadena_original(xml)
  xslt = Nokogiri::XSLT(File.read("/home/daniel/Documentos/sysChurch/lib/cadenaoriginal_3_3.xslt"))
  cadena = xslt.transform(xml)
  cadena.text.gsub("\n","")
end

#Actualizar la fecha del xml a la actual
def actualizar_fecha(comprobante)
  #Actualizar fecha del nodo Fecha
  node = comprobante.xpath('//@Fecha')[0]
  fecha = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
  node.content = fecha
  comprobante
end

#Actualizar el sello del comprobante
def actualizar_sello(comprobante, sello)
  node = comprobante.xpath('//@Sello')[0]
  node.content = sello
  comprobante.to_xml
end

def timbrar_xml(usuario, contrasena, xml_base64, wsdl_url)
  # Generar el Envelope
  envelope = %Q^
    <soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:WashOut\">
      <soapenv:Header/>
      <soapenv:Body>
        <urn:timbrar_cfdi soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
          <username xsi:type=\"xsd:string\">#{usuario}</username>
          <password xsi:type=\"xsd:string\">#{contrasena}</password>
          <sxml xsi:type=\"xsd:string\">#{xml_base64}</sxml>
      </urn:timbrar_cfdi>
      </soapenv:Body>
    </soapenv:Envelope>^

  # Crear un cliente de savon para hacer la petición al WS, en produccion quitar el "log: true"
  client = Savon.client(wsdl: wsdl_url, log: true)

  # Llamar el metodo timbrar
  response = client.call(:timbrar_cfdi, { "xml" => envelope })

  # Extraer el xml timbrado desde la respuesta del WS
  response = response.to_hash
  xml_timbrado = response[:timbrar_cfdi_response][:timbrar_cfdi_result][:xml]#xml sin alteraciones listo para entregar al cliente.

  document = Nokogiri::XML(xml_timbrado)
end

#Función para la cancelación de los CFDIs.
def cancelar_cfdi
  # Generar el Envelope para el metodo cancelar
  envelope = %Q^
  <soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:WashOut\">
     <soapenv:Header/>
     <soapenv:Body>
      <urn:cancelar_cfdi soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
         <username xsi:type=\"xsd:string\">#{usuario}</username>
         <password xsi:type=\"xsd:string\">#{contrasena}</password>
         <rfcemisor xsi:type=\"xsd:string\">#{rfc}</rfcemisor>
         <uuids xsi:type=\"urn:uuids\">
            <uuid xsi:type=\"xsd:string\">#{uuid}</uuid>
         </uuids>
         <pfxbase64 xsi:type=\"xsd:string\">#{pfx_base64}</pfxbase64>
         <pfxpassword xsi:type=\"xsd:string\">#{pfx_password}</pfxpassword>
      </urn:cancelar_cfdi>
   </soapenv:Body>
  </soapenv:Envelope>^

  # Crear un cliente de savon para hacer la conexión al WS, en produccion quital el "log: true"
  client = Savon.client(wsdl: wsdl_url, log: true)

  # Hacer el llamado al metodo cancelar_cfdi
  response = client.call(:cancelar_cfdi, { "xml" => envelope })

  documento = Nokogiri::XML(response.to_xml)

  # Obenter el acuse de cancelación
  acuse = documento.xpath("//acuse_cancelacion").text
  #puts acuse

  # Obtener los estatus de los comprobantes cancelados
  uuids_cancelados = documento.xpath("//comprobantes_cancelados").text
  #puts uuids_cancelados
end
