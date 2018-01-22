require 'base64'
require 'savon'
require 'nokogiri'
require 'byebug'

def generar_sello(comprobante, path_llave, password_llave)
  comprobante = Nokogiri::XML(comprobante)
  comprobante = actualizar_fecha(comprobante)
  puts cadena = get_cadena_original(comprobante)

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
