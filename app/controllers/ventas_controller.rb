class VentasController < ApplicationController

  before_action :set_venta, only: [:show, :edit, :update, :destroy]
  before_action :set_cajeros, only: [:index, :consulta_ventas, :consulta_avanzada, :solo_sucursal]
  before_action :set_sucursales, only: [:index, :consulta_ventas, :consulta_avanzada, :solo_sucursal]
  before_action :set_categorias_cancelacion, only: [:index, :consulta_ventas, :consulta_avanzada, :solo_sucursal, :edit, :update, :show]

  def index
    @consulta = false
    @avanzada = false
    if request.get?
      if can? :create, Negocio
        @ventas = current_user.negocio.ventas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      else
        @ventas = current_user.sucursal.ventas.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      end
    end
  end

  def show
    if @venta.cliente
      @cliente = @venta.cliente.nombre_completo
    else
      @cliente = ""
    end

    @sucursal = @venta.sucursal.nombre
    @cajero = @venta.user.perfil ? @venta.user.perfil.nombre_completo : @venta.user.email
    @items = @venta.item_ventas
    if @venta.venta_canceladas
      @devoluciones = @venta.venta_canceladas
    end
    @formaPago = @venta.venta_forma_pago.forma_pago.nombre
    @camposFormaPago = @venta.venta_forma_pago.venta_forma_pago_campos


  end

  def new
  end

  def edit
    @items = @venta.item_ventas
    plantilla_email("ac_fv")
  end

  def create
  end

  def update
    respond_to do |format|
      categoria = params[:cat_cancelacion]
      cat_venta_cancelada = CatVentaCancelada.find(categoria)
      venta = params[:venta]
      observaciones = venta[:observaciones]
      @items = @venta.item_ventas
      #Changos que hacen estas cosas aquí? jajja
      require 'timbrado'
      require 'nokogiri'
      require 'byebug'

      if @venta.update(:observaciones => observaciones, :status => "Cancelada")

        if @venta.factura.present?
          if @venta.factura.estado_factura == "Activa"
              # Parametros para la conexión al Webservice
              wsdl_url = "https://staging.ws.timbox.com.mx/timbrado_cfdi33/wsdl"
              usuario = "AAA010101000"
              contrasena = "h6584D56fVdBbSmmnB"

              # Parametros para la cancelación del CFDI
              uuid = @venta.factura.folio_fiscal
              rfc = "AAA010101AAA"
              pfx_path = '/home/daniel/Documentos/timbox-ruby/archivoPfx.pfx'
              bin_file = File.binread(pfx_path)
              pfx_base64 = Base64.strict_encode64(bin_file)
              pfx_password = "12345678a"
              #Se cancela
              xml_cancelado = cancelar_cfdis usuario, contrasena, rfc, uuid, pfx_base64, pfx_password, wsdl_url
              #se extrae el acuse de cancelación del xml cancelado
              acuse = xml_cancelado.xpath("//acuse_cancelacion").text

              gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
              storage=gcloud.storage
              bucket = storage.bucket "cfdis"
              #Consultas
              ruta_storage = @venta.factura.ruta_storage
              fecha_expedicion=@venta.factura.fecha_expedicion
              consecutivo =@venta.factura.consecutivo
              file_name = "#{consecutivo}_#{fecha_expedicion}"
              #Se guarda el Acuse en la nube
              file = bucket.create_file StringIO.new(acuse.to_s), "#{ruta_storage}_AcuseDeCancelación.xml"

              #Si una venta tiene una factura asociada se cancela como consecuencia.
              @venta.factura.update( estado_factura: "Cancelada") #Pasa de activa a cancelada

              acuse = Nokogiri::XML(acuse)

              a = File.open("public/#{file_name}_AcuseDeCancelación", "w")
              a.write (acuse)
              a.close

              #Se envia el acuse de cancelación al correo electrónico del fulano zutano perengano
              destinatario = params[:destinatario]
              plantilla_email("ac_fv")
              
              comprobantes = {xml_Ac: "public/#{file_name}_AcuseDeCancelación"}
              FacturasEmail.factura_email(destinatario, @mensaje, @asunto, comprobantes).deliver_now
          end
        end

        #Se obtiene el movimiento de caja de sucursal, de la venta que se quiere cancelar
        movimiento_caja = @venta.movimiento_caja_sucursal

        #Si el pago de la venta se realizó en efectivo, entonces se añade el monto de la venta al saldo de la caja
        if movimiento_caja.tipo_pago.eql?("efectivo")
          caja_sucursal = @venta.caja_sucursal
          saldo = caja_sucursal.saldo
          saldoActualizado = saldo - @venta.montoVenta
          caja_sucursal.saldo = saldoActualizado
          caja_sucursal.save
        end

        #Se elimina el movimiento de caja relacionado con la venta
        movimiento_caja.destroy

        #Por cada item de venta, se crea un registro de venta cancelada.
        @venta.item_ventas.each do |itemVenta|
          ventaCancelada = VentaCancelada.new(:articulo => itemVenta.articulo, :item_venta => itemVenta, :venta => @venta, :cat_venta_cancelada=>cat_venta_cancelada, :user=>current_user, :observaciones=>observaciones, :negocio=>@venta.negocio, :sucursal=>@venta.sucursal, :cantidad_devuelta=>itemVenta.cantidad, :monto=>itemVenta.monto)
          ventaCancelada.save
          itemVenta.status = "Con devoluciones"
          itemVenta.save
        end

        format.json { head :no_content}
        format.js
      else
        format.json {render json: @venta.errors.full_messages, status: :unprocessable_entity}
        format.js {render :edit}
      end

    end
  end

  def destroy

  end

  def buscarUltimoFolio
    @folio = current_user.sucursal.ventas.last.folio

    render :json => @folio

  end

  def consulta_ventas
    @consulta = true
    @avanzada = false
    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final]).to_date
      if can? :create, Negocio
        @ventas = current_user.negocio.ventas.where(fechaVenta: @fechaInicial..@fechaFinal)
      else
        @ventas = current_user.sucursal.ventas.where(fechaVenta: @fechaInicial..@fechaFinal)
      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end

  def consulta_avanzada
    @consulta = true
    @avanzada = true
    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial_avanzado]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final_avanzado]).to_date
      perfil_id = params[:perfil_id]
      @cajero = nil
      unless perfil_id.empty?
        @cajero = Perfil.find(perfil_id).user
      end

      @status = params[:status]

      @suc = params[:suc_elegida]

      unless @suc.empty?
        @sucursal = Sucursal.find(@suc)
      end

      #Resultados para usuario administrador o subadministrador
      if can? :create, Negocio
        unless @suc.empty?
          #valida si se eligió un cajero específico para esta consulta
          if @cajero
            #Si el status elegido es todas, entonces no filtra las ventas por el status
            unless @status.eql?("Todas")
              @ventas = current_user.negocio.ventas.where(fechaVenta: @fechaInicial..@fechaFinal, user: @cajero, status: @status, sucursal: @sucursal)
            else
              @ventas = current_user.negocio.ventas.where(fechaVenta: @fechaInicial..@fechaFinal, user: @cajero, sucursal: @sucursal)
            end

          # Si no se eligió cajero, entonces no filtra las ventas por el cajero vendedor
          else
            #Si el status elegido es todas, entonces no filtra las ventas por el status
            unless @status.eql?("Todas")
              @ventas = current_user.negocio.ventas.where(fechaVenta: @fechaInicial..@fechaFinal, status: @status, sucursal: @sucursal)
            else
              @ventas = current_user.negocio.ventas.where(fechaVenta: @fechaInicial..@fechaFinal, sucursal: @sucursal)
            end
          end

        #Si el usuario no eligió ninguna sucursal específica, no filtra las ventas por sucursal
        else
          #valida si se eligió un cajero específico para esta consulta
          if @cajero
            #Si el status elegido es todas, entonces no filtra las ventas por el status
            unless @status.eql?("Todas")
              @ventas = current_user.negocio.ventas.where(fechaVenta: @fechaInicial..@fechaFinal, user: @cajero, status: @status)
            else
              @ventas = current_user.negocio.ventas.where(fechaVenta: @fechaInicial..@fechaFinal, user: @cajero)
            end

          # Si no se eligió cajero, entonces no filtra las ventas por el cajero vendedor
          else
            #Si el status elegido es todas, entonces no filtra las ventas por el status
            unless @status.eql?("Todas")
              @ventas = current_user.negocio.ventas.where(fechaVenta: @fechaInicial..@fechaFinal, status: @status)
            else
              @ventas = current_user.negocio.ventas.where(fechaVenta: @fechaInicial..@fechaFinal)
            end
          end
        end

      #Si el usuario no es un administrador o subadministrador
      else

        #valida si se eligió un cajero específico para esta consulta
        if @cajero

          #Si el status elegido es todas, entonces no filtra las ventas por el status
          unless @status.eql?("Todas")
            @ventas = current_user.sucursal.ventas.where(fechaVenta: @fechaInicial..@fechaFinal, user: @cajero, status: @status)
          else
            @ventas = current_user.sucursal.ventas.where(fechaVenta: @fechaInicial..@fechaFinal, user: @cajero)
          end #Termina unless @status.eql?("Todas")

        # Si no se eligió cajero, entonces no filtra las ventas por el cajero vendedor
        else

          #Si el status elegido es todas, entonces no filtra las ventas por el status
          unless @status.eql?("Todas")
            @ventas = current_user.sucursal.ventas.where(fechaVenta: @fechaInicial..@fechaFinal, status: @status)
          else
            @ventas = current_user.sucursal.ventas.where(fechaVenta: @fechaInicial..@fechaFinal)
          end #Termina unless @status.eql?("Todas")

        end #Termina if @cajero

      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end

  def solo_sucursal
    @consulta = false
    @avanzada = false
    if request.post?
      @ventas = current_user.sucursal.ventas
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end

  def venta_del_dia

    if request.get?
      @fechaCorrecta = Date.today

      @ventasNegocioHoy = current_user.negocio.ventas.where(fechaVenta: Date.today)

      @ventasNegocioMes = current_user.negocio.ventas.where(fechaVenta: Date.today.beginning_of_month..Date.today)

      @ventaDiaNegocio = 0

      @ventaMesNegocio = 0

      @ventasNegocioHoy.each do |venta|
        @ventaDiaNegocio += venta.montoVenta.to_f
      end

      @ventasNegocioMes.each do |venta|
        @ventaMesNegocio += venta.montoVenta.to_f
      end

      @sucursales = current_user.negocio.sucursals

      @usuarios = current_user.negocio.users

    elsif request.post?

      fecha = params[:Fecha]
      @fechaCorrecta = DateTime.parse(fecha).to_date

      @ventasNegocioHoy = current_user.negocio.ventas.where(fechaVenta: @fechaCorrecta)

      @ventasNegocioMes = current_user.negocio.ventas.where(fechaVenta: @fechaCorrecta.beginning_of_month..@fechaCorrecta.end_of_month)

      @ventaDiaNegocio = 0

      @ventaMesNegocio = 0

      @ventasNegocioHoy.each do |venta|
        @ventaDiaNegocio += venta.montoVenta.to_f
      end

      @ventasNegocioMes.each do |venta|
        @ventaMesNegocio += venta.montoVenta.to_f
      end

      @sucursales = current_user.negocio.sucursals

      @usuarios = current_user.negocio.users

    end


  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_venta
      @venta = Venta.find(params[:id])
    end

    def set_cajeros
      @cajeros = []
      if can? :create, Negocio
        current_user.negocio.users.each do |cajero|
          #Llena un array con todos los cajeros del negocio
          #(usuarios del negocio que pueden hacer una venta, no solo el rol de cajero)
          #Siempre y cuando no sean auxiliares o almacenistas pues no tienen acceso a punto de venta
          if cajero.role != "auxiliar" || cajero.role != "almacenista"
            @cajeros.push(cajero.perfil)
          end
        end
      else
        current_user.sucursal.users.each do |cajero|
          #Llena un array con todos los cajeros de la sucursal
          #(usuarios de la sucursal que pueden hacer una venta, no solo el rol de cajero)
          #Siempre y cuando no sean auxiliares o almacenistas pues no tienen acceso a punto de venta
          if cajero.role != "auxiliar" || cajero.role != "almacenista"
            @cajeros.push(cajero.perfil)
          end
        end
      end
    end

    def set_sucursales
      @sucursales = current_user.negocio.sucursals
    end

    #Asigna lista de categorias de devolucion de ventas
    def set_categorias_cancelacion
        @categorias_devolucion = current_user.negocio.cat_venta_canceladas
    end
    #Esta función sirve para optener la plantilla de email para el envío del acuse de cancelación de la factura de venta
    def plantilla_email (opc)
      require 'plantilla_email/plantilla_email.rb'

      mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: opc).msg_email
      asunto = current_user.negocio.plantillas_emails.find_by(comprobante: opc).asunto_email

      cadena = PlantillaEmail::AsuntoMensaje.new
      cadena.nombCliente = @venta.factura.cliente.nombre_completo #if mensaje.include? "{{Nombre del cliente}}"
      cadena.fechaVta = @venta.fechaVenta 
      cadena.numVta = @venta.consecutivo
      cadena.folioVta = @venta.folio
      cadena.fechaFact = @venta.factura.fecha_expedicion
      cadena.numFact = @venta.factura.consecutivo
      cadena.folioFact = @venta.factura.folio
      cadena.totalFact = @venta.montoVenta #El total 
      cadena.nombNegocio = @venta.factura.negocio.nombre 
      cadena.nombSucursal = @venta.factura.sucursal.nombre
      cadena.emailContacto = @venta.factura.sucursal.email
      cadena.telContacto = @venta.factura.sucursal.telefono

      @mensaje = cadena.reemplazar_texto(mensaje)
      @asunto = cadena.reemplazar_texto(asunto)

    end


end
