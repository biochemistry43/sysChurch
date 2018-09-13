class NotaCreditosController < ApplicationController
  before_action :set_nota_credito, only: [:show, :edit, :update, :destroy, :imprimirpdf, :descargar_nota_credito, :mostrar_email_nota_credito, :enviar_nota_credito, :mostrar_email_cancelacion_nc, :cancelar_nota_credito]
  #before_action :set_sucursales, only: [:index, :consulta_avanzada]
  before_action :set_clientes, only: [:index, :consulta_por_fecha, :consulta_por_folio, :consulta_por_cliente, :consulta_avanzada, :consulta_por_cfdi_relacionado]
  before_action :set_sucursales, only: [:index, :consulta_por_fecha, :consulta_por_folio, :consulta_por_cliente, :consulta_avanzada, :consulta_por_cfdi_relacionado]

  # GET /nota_creditos
  # GET /nota_creditos.json
  def index
    @consulta = false
    @avanzada = false

    if request.get?
      if can? :create, Negocio

        @nota_creditos = current_user.negocio.nota_creditos.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      else
        @nota_creditos = current_user.sucursal.nota_creditos.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month).order(created_at: :desc)
      end
    end
  end

  # GET /nota_creditos/1
  # GET /nota_creditos/1.json
  def show
  end

  # GET /nota_creditos/new
  def new
    @nota_credito = NotaCredito.new
  end

  # GET /nota_creditos/1/edit
  def edit
  end

  # POST /nota_creditos
  # POST /nota_creditos.json
  def create
    @nota_credito = NotaCredito.new(nota_credito_params)

    respond_to do |format|
      if @nota_credito.save
        format.html { redirect_to @nota_credito, notice: 'Nota credito was successfully created.' }
        format.json { render :show, status: :created, location: @nota_credito }
      else
        format.html { render :new }
        format.json { render json: @nota_credito.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nota_creditos/1
  # PATCH/PUT /nota_creditos/1.json
  def update
    respond_to do |format|
      if @nota_credito.update(nota_credito_params)
        format.html { redirect_to @nota_credito, notice: 'Nota credito was successfully updated.' }
        format.json { render :show, status: :ok, location: @nota_credito }
      else
        format.html { render :edit }
        format.json { render json: @nota_credito.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nota_creditos/1
  # DELETE /nota_creditos/1.json
  def destroy
    @nota_credito.destroy
    respond_to do |format|
      format.html { redirect_to nota_creditos_url, notice: 'Nota credito was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  #FILTROS PARA LAS NOTAS DE CRÉDITO
  def consulta_por_fecha
    @consulta = true
    @fechas=true
    @por_folio=false
    @avanzada = false
    @por_cliente= false

    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final]).to_date
      if can? :create, Negocio
        @nota_creditos = current_user.negocio.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal)
      else
        @nota_creditos = current_user.sucursal.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal)
      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end

  def consulta_por_folio
    @consulta = true
    @fechas = false
    @por_folio = true
    @avanzada = false
    @por_cliente= false

    if request.post?
      @folio_nc = params[:folio_nc]
      #@facturas = Factura.find_by folio: @folio_nc
      if can? :create, Negocio
        @nota_creditos = current_user.negocio.nota_creditos.where(folio: @folio_nc)
      else
        @nota_creditos = current_user.sucursal.nota_creditos.where(folio: @folio_nc)
      end
    end
  end

  def consulta_por_cliente
    @consulta = true
    @fechas = false
    @por_folio = false
    @avanzada = false
    @por_cliente= true

    if request.post?

      if can? :create, Negocio
        #@facturas = current_user.negocio.facturas.where(cliente_id: current_user.negocio.clientes.where(id:(DatosFiscalesCliente.find_by rfc: @rfc).cliente_id))
        if params[:rbtn] == "rbtn_rfc"
          #Se puede presentar el caso en el que un negocio tenga clientes con el mismo RFC y/o nombres fiscales iguales como datos de facturción.
          #El resultado de la búsqueda serían todas las facturas de los diferentes clientes con el RFC igual. (incluyendo el XAXX010101000)
          @rfc = params[:rfc]
          datos_fiscales_cliente = DatosFiscalesCliente.where rfc: @rfc
          #datos_fiscales_cliente = current_user.negocio.clientes.where(datos_fiscales_clientes rfc: @rfc
          clientes_ids = []
          datos_fiscales_cliente.each do |dfc|
            clientes_ids << dfc.cliente_id
          end
          #Se le pasa un arreglo con los ids para obtener las facturas de todos los clientes con el RFC =
          @nota_creditos = current_user.negocio.nota_creditos.where(cliente_id: clientes_ids)
          #cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
        elsif params[:rbtn] == "rbtn_nombreFiscal"
          #En el caso de la búsqueda por nombre fiscal... el resutado serán todas las facturas de un único cliente.
          datos_fiscales_cliente = DatosFiscalesCliente.find params[:cliente_id]
          @nombreFiscal = datos_fiscales_cliente.nombreFiscal
          cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
          @nota_creditos = current_user.negocio.nota_creditos.where(cliente_id: cliente)
        end

      else
        if params[:rbtn] == "rbtn_rfc"
          #Se puede presentar el caso en el que un negocio tenga clientes con el mismo RFC y/o nombres fiscales iguales como datos de facturción.
          #El resultado de la búsqueda serían todas las facturas de los diferentes clientes con el RFC igual. (incluyendo el XAXX010101000)
          @rfc = params[:rfc]
          datos_fiscales_cliente = current_user.sucursal.clientes.datos_fiscales_cliente.where rfc: @rfc
          clientes_ids = []
          datos_fiscales_cliente.each do |dfc|
            clientes_ids << dfc.cliente_id
          end
          @nota_creditos = current_user.sucursal.nota_creditos.where(cliente_id: clientes_ids)
          #cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
        elsif params[:rbtn] == "rbtn_nombreFiscal"
          #En el caso de la búsqueda por nombre fiscal... el resutado serán todas las facturas de un único cliente.
          datos_fiscales_cliente = DatosFiscalesCliente.find params[:cliente_id]
          @nombreFiscal = datos_fiscales_cliente.nombreFiscal
          cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
          @nota_creditos = current_user.sucursal.nota_creditos.where(cliente_id: cliente)
        end
      end
    end
  end

  #Ésta función permite obtener las notas de crédito pertenecientes a una factura de venta.  
  def consulta_por_cfdi_relacionado
    @consulta = true
    @fechas = false
    @por_folio = false
    @avanzada = false
    @por_cliente= false
    @por_cfd_relacionado = true

    if request.post?
      @folio_nc = params[:folio_fv]
      if can? :create, Negocio
        
        factura = current_user.negocio.facturas.find_by(folio: params[:folio_fv])
        if factura 
          @nota_creditos = []
          notaCreditosFacturaVenta = factura.factura_nota_creditos
          notaCreditosFacturaVenta.each do |nc_fv|
          @nota_creditos << nc_fv.nota_credito
          end
        else
          #La mera neta del planeta con esta salgo jeje 
          #Me muero de programador... Se realiza una consulta que jamás se cumplirá poq en la vista el each...
          @nota_creditos = current_user.negocio.nota_creditos.where(id: nil)
        end
      else

        factura = current_user.sucursal.facturas.find_by(folio: params[:folio_fv])
        if factura
          @nota_creditos = []
          notaCreditosFacturaVenta = factura.factura_nota_creditos
          notaCreditosFacturaVenta.each do |nc_fv|
            #También se obtienen solo las notas de crédito de la sucursal 
            @nota_creditos << nc_fv.nota_credito if current_user.sucursal.nota_creditos.find_by(id: nc_fv.nota_credito)
          end
        else
          #La explicación de esta línea esta arriba jaja
          @nota_creditos = current_user.sucursal.nota_creditos.where(id: nil)
        end        
      end
    end
  end


  def consulta_avanzada

    @consulta = true
    @avanzada = true
    @fechas=false
    @por_folio=false

    #@clientes = current_user.negocio.clientes.nombre
    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial_avanzado]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final_avanzado]).to_date

      clientes_ids = []
      if params[:opcion_busqueda_cliente] == "Buscar por R.F.C."
        #Se puede presentar el caso en el que un negocio tenga clientes con el mismo RFC y/o nombres fiscales iguales como datos de facturción.
        #El resultado de la búsqueda serían todas las facturas de los diferentes clientes con el RFC igual. (incluyendo el XAXX010101000)
        @rfc = params[:rfc]
        @por_cliente = true if @rfc
        datos_fiscales_cliente = DatosFiscalesCliente.where rfc: @rfc

        datos_fiscales_cliente.each do |dfc|
          clientes_ids << dfc.cliente_id
        end
        #Se le pasa un arreglo con los ids para obtener las facturas de todos los clientes con el RFC =
        #@facturas = current_user.negocio.facturas.where(cliente_id: clientes_ids)
        #cliente = datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
      elsif params[:opcion_busqueda_cliente] == "Buscar por nombre fiscal"

        #En el caso de la búsqueda por nombre fiscal... el resutado serán todas las facturas de un único cliente.
        datos_fiscales_cliente = DatosFiscalesCliente.find params[:cliente_id]
        @por_cliente = true
        @nombreFiscal = datos_fiscales_cliente.nombreFiscal
        clientes_ids << datos_fiscales_cliente.cliente_id if datos_fiscales_cliente
        #@facturas = current_user.negocio.facturas.where(cliente_id: cliente)
      end

      @estado = params[:estado_nc]

      @suc = params[:suc_elegida]

      unless @suc.empty?
        @sucursal = Sucursal.find(@suc)
      end
      @monto_nc = false
      @condicion_monto_nc = params[:condicion_monto_nc]

      #Se convierte la descripción al operador equivalente
      unless @condicion_monto_nc.empty?
        @monto_nc = true
        operador_monto = case @condicion_monto_nc
           when "menor que" then "<"
           when "mayor que" then ">"
           when "menor o igual que" then "<="
           when "mayor o igual que" then ">="
           when "igual que" then "="
           when "diferente que" then "!=" #o también <> Distinto de
           when "rango desde" then ".." #o también <> Distinto de
        end
      end

      if can? :create, Negocio
        unless @suc.empty?
          #valida si se eligió un cliente específico para esta consulta
          if @rfc || @nombreFiscal#@cliente
            #Filtra por monto de la venta facurada.
            if operador_monto
              @monto1 = params[:monto1]
              unless operador_monto == ".." #Cuando se trata de un rango
                @nota_creditos = current_user.negocio.nota_creditos.where("monto #{operador_monto} ?", @monto1) if @monto1
              else
                @monto2 = params[:monto2]
                @nota_creditos = current_user.negocio.nota_creditos.where(monto: @monto1..@monto2) if @monto1 && @monto2
              end
              #Si el estado elegido es todas, entonces no filtra los comprobantes por el estado del comprobante
              unless @estado.eql?("Todas")
                @nota_creditos = @nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_nc: @estado, sucursal: @sucursal)
              else
                @nota_creditos = @nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, sucursal: @sucursal)
              end
            else
              #Si el estado elegido es todas, entonces no filtra los comprobantes por el estado del comprobante
              unless @estado.eql?("Todas")
                @nota_creditos = current_user.negocio.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_nc: @estado, sucursal: @sucursal)
              else
                @nota_creditos = current_user.negocio.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, sucursal: @sucursal)
              end
            end
          # Si no se eligió cliente, entonces no filtra los comprobantes el cliente al que se expidió el comprobante
          else
            #Filtra por monto de la venta facurada.
            if operador_monto
              @monto1 = params[:monto1]
              unless operador_monto == ".." #Cuando se trata de un rango
                @nota_creditos = current_user.negocio.nota_creditos.where("monto #{operador_monto} ?", @monto1) if @monto1
              else
                @monto2 = params[:monto2]
                @nota_creditos = current_user.negocio.nota_creditos.where(monto: @monto1..@monto2) if @monto1 && @monto2
              end
              #Si el estado elegido es todas, entonces no filtra los comprobantes el estado del comprobante
              unless @estado.eql?("Todas")
                @nota_creditos = @nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_nc: @estado, sucursal: @sucursal)
              else
                @nota_creditos = @nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal)
              end
              #Si el usuario no seleccionó una condición para filtrar por el monto del comprobante
            else
              #Si el estado elegido es todas, entonces no filtra los comprobantes el estado del comprobante
              unless @estado.eql?("Todas")
                @nota_creditos = current_user.negocio.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_nc: @estado, sucursal: @sucursal)
              else
                @nota_creditos = current_user.negocio.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, sucursal: @sucursal)
              end
            end
          end
        #Si el usuario no eligió ninguna sucursal específica, no filtra los comprobantes por sucursal
        else
          #valida si se eligió un cliente
          if @rfc || @nombreFiscal#@cliente
            #Filtra por monto de la nota de crédito
            if operador_monto
              @monto1 = params[:monto1]
              unless operador_monto == ".." #Cuando se trata de un rango
                @nota_creditos = current_user.negocio.nota_creditos.where("monto #{operador_monto} ?", @monto1) if @monto1
              else
                @monto2 = params[:monto2]
                @nota_creditos = current_user.negocio.nota_creditos.where(monto: @monto1..@monto2) if @monto1 && @monto2
              end
              #Si el estado elegido es todas, entonces no filtra los comprobantes por el estado
              unless @estado.eql?("Todas")
                @nota_creditos = @nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_nc: @estado)
              else
                @nota_creditos = @nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids)
              end
            else
              #Si el estado elegido es todas, entonces no filtra las notas de crédito por el estado
              unless @estado.eql?("Todas")
                @nota_creditos = current_user.negocio.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_nc: @estado)
              else
                @nota_creditos = current_user.negocio.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids)
              end
            end
          # Si no se eligió cliente, entonces no filtra las notas de crédito por el cliente
          else
            if operador_monto
              @monto1= params[:monto1]
              unless operador_monto == ".." #Cuando se trata de un rango
                @nota_creditos = current_user.negocio.nota_creditos.where("monto #{operador_monto} ?", @monto1) if @monto1
              else
                @monto2 = params[:monto2]
                @nota_creditos = current_user.negocio.nota_creditos.where(monto: @monto1..@monto2) if @monto1 && @monto2
              end
              #Si el estado elegido es todas, entonces no filtra los comprobantes por el estado del comprobante
              unless @estado.eql?("Todas")
                @nota_creditos = @nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_nc: @estado)
              else
                @nota_creditos = @nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal)
              end
            else
              #Si el estado elegido es todas, entonces no filtra los comprobantes por el estado del comprobante
              unless @estado.eql?("Todas")
                @nota_creditos = current_user.negocio.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_nc: @estado)
              else
                @nota_creditos = current_user.negocio.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal)
              end
            end
          end
        end

      #Si el usuario no es un administrador o subadministrador
      else

        #valida si se eligió un cliente específico para esta consulta
        if @rfc || @nombreFiscal#@cliente

          #Si el estado elegido es todas, entonces no filtra los comprobantes por el estado del comprobante
          unless @estado.eql?("Todas")
            @nota_creditos = current_user.sucursal.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids, estado_nc: @estado)
          else
            @nota_creditos = current_user.sucursal.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, cliente: clientes_ids)
          end #Termina unless @estado.eql?("Todas")

        # Si no se eligió cliente, entonces no filtra los comprobantes el cliente
        else

          #Si el estado elegido es todas, entonces no filtra los comprobantes por el estado del comprobante
          unless @estado.eql?("Todas")
            @nota_creditos = current_user.sucursal.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal, estado_nc: @estado)
          else
            @nota_creditos = current_user.sucursal.nota_creditos.where(fecha_expedicion: @fechaInicial..@fechaFinal)
          end #Termina unless @estado.eql?("Todas")

        end #Termina if @cajero

      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end


  #Acción para imprimir la nota de crédito
  def imprimirpdf

    gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
    storage=gcloud.storage
    bucket = storage.bucket "cfdis"
    ruta_storage = @nota_credito.ruta_storage
    uuid_cfdi = @nota_credito.folio_fiscal

    file_download_storage = bucket.file "#{ruta_storage}#{uuid_cfdi}.pdf"
    file_download_storage.download "public/#{uuid_cfdi}.pdf"


    #Se comprueba que el archivo exista en la carpeta publica de la aplicación
    if File::exists?( "public/#{uuid_cfdi}.pdf")
      file=File.open( "public/#{uuid_cfdi}.pdf")
      send_file( file, :disposition => "inline", :type => "application/pdf")
      #File.delete("public/#{file_name}")
    else
      respond_to do |format|
        format.html { redirect_to action: "index" }
        flash[:notice] = "No se pudo mostrar la nota de crédito, vuelva a intentarlo por favor."
        #format.html { redirect_to facturas_index_path, notice: 'No se encontró la factura, vuelva a intentarlo!' }
      end
    end
  end


    def descargar_nota_credito
      gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
      storage=gcloud.storage
      bucket = storage.bucket "cfdis"

      ruta_storage = @nota_credito.ruta_storage

      #Se descarga el pdf de la nube y se guarda en el disco
      file_download_storage_xml = bucket.file "#{ruta_storage}.xml"
      file_download_storage_xml.download "public/#{@nota_credito.id}.xml"

      xml = File.open( "public/#{@nota_credito.id}.xml")
      send_file(
        xml,
        filename: "CFDI.xml",
        type: "application/xml"
      )
    end

    def enviar_nota_credito
      #Se optienen los datos que se ingresen o en su caso los datos de la configuracion del mensaje de los correos.
      if request.post?
        destinatario_final = params[:destinatario]

        if @nota_credito.estado_nc == "Activa"
          if @nota_credito.tipo_factura == "fv"
            plantilla_email("nc_fv")
          elsif @nota_credito.tipo_factura== "fg"
            plantilla_email("nc_fg")
          end
        elsif @nota_credito.estado_nc == "Cancelada"
          if @nota_credito.tipo_factura == "fv"
            plantilla_email("ac_nc_fv")
          elsif @nota_credito.tipo_factura== "fg"
            plantilla_email("ac_nc_fg")
          end
        end

        ruta_storage_nc = @nota_credito.ruta_storage
        #ruta_storage_fv = @nota_credito.factura.ruta_storage
        #Se descargan los archivos que el usuario haya indicado que se enviarán como archivos adjuntos
        gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
        storage=gcloud.storage
        bucket = storage.bucket "cfdis"

        #Se dice que cundo se envia una nota de credito también se debe de enviar los comprobates de ingreso(facturas de vetas), para que el cliente compruebe la diferencia entre los montos.
        comprobantes = {}
        if params[:pdf_nc] == "yes"
          comprobantes[:pdf_nc] = "public/#{@nota_credito.id}.pdf"
          file_download_storage_xml = bucket.file "#{ruta_storage_nc}.pdf"
          file_download_storage_xml.download "public/#{@nota_credito.id}.pdf"
        end

        if params[:xml_nc] == "yes"
          comprobantes[:xml_nc] = "public/#{@nota_credito.id}.xml"
          file_download_storage_xml = bucket.file "#{ruta_storage_nc}.xml"
          file_download_storage_xml.download "public/#{@nota_credito.id}.xml"
        end
        #Solo cuando este cancelada
        if @nota_credito.estado_nc == "Cancelada"
          ruta_storage_ac_nc = @nota_credito.nota_credito_cancelada.ruta_storage
          if params[:xml_Ac_nc] == "yes"
            comprobantes[:xml_Ac_nc] = "public/#{@nota_credito.nota_credito_cancelada.id}.xml"
            file_download_storage_xml = bucket.file "#{ruta_storage_ac_nc}.xml"
            file_download_storage_xml.download "public/#{@nota_credito.nota_credito_cancelada.id}.xml"
          end
        end

        #Por si el usuario también desea enviar la factura de venta relacionada a la nota de crédito
        if params[:pdf] == "yes"
          comprobantes[:pdf] = "public/#{@nota_credito.factura.id}.pdf"
          file_download_storage_xml = bucket.file "#{ruta_storage_fv}.pdf"
          file_download_storage_xml.download "public/#{@nota_credito.factura.id}.pdf"
        end
        if params[:xml] == "yes"
          comprobantes[:xml] = "public/#{@nota_credito.factura.id}.xml"
          file_download_storage_xml = bucket.file "#{ruta_storage_fv}.xml"
          file_download_storage_xml.download "public/#{@nota_credito.factura.id}.xml"
        end

        #FacturasEmail.factura_email(@destinatario, @mensaje, @tema).deliver_now
        FacturasEmail.factura_email(destinatario_final, @mensaje, @asunto, comprobantes).deliver_now

        respond_to do |format|
          format.html { redirect_to action: "index"}
          flash[:notice] = "Los comprobantes se han enviado a #{destinatario_final}!"
          #format.html { redirect_to facturas_index_path, notice: 'No se encontró la factura, vuelva a intentarlo!' }
        end
      end
    end

    def mostrar_email_nota_credito
      #Solo se muestran los datos
      @destinatario = @nota_credito.cliente.email

      if @nota_credito.estado_nc == "Activa"
        if @nota_credito.tipo_factura == "fv"
          plantilla_email("nc_fv")
        elsif @nota_credito.tipo_factura== "fg"
          plantilla_email("nc_fg")
        end
      elsif @nota_credito.estado_nc == "Cancelada"
        if @nota_credito.tipo_factura == "fv"
          plantilla_email("ac_nc_fv")
        elsif @nota_credito.tipo_factura== "fg"
          plantilla_email("ac_nc_fg")
        end
      end
    end

    #Para cancelar una nota de crédito de una perteneciente a una factura.
    def mostrar_email_cancelacion_nc
      if @nota_credito.tipo_factura == "fv"
        plantilla_email("ac_nc_fv")
      elsif @nota_credito.tipo_factura== "fg"
        plantilla_email("ac_nc_fg")
      end
      #@categorias_devolucion = current_user.negocio.cat_venta_canceladas
    end

    def cancelar_nota_credito
      #De acuerdo a la regla 2.7.1.39 de la Resolución Miscelánea Fiscal para el 2018, los contribuyentes podrán cancelar un CFDI sin que se requiera la aceptación por parte del receptor en los siguientes supuestos:
      #...
      # => Por concepto de egresos.
      #... sha la la sha la la
      require 'timbrado'
      require 'base64'
      #equire 'savon'
      require 'nokogiri'
      require 'byebug'
      require 'openssl'

      username = "AAA010101000"
      password = "h6584D56fVdBbSmmnB"
      rfc_emisor  = @nota_credito.negocio.datos_fiscales_negocio.rfc

      folios =  %Q^<folio>
                  <uuid xsi:type="xsd:string">#{@nota_credito.folio_fiscal}</uuid>
                  <rfc_receptor xsi:type="xsd:string">#{@nota_credito.cliente.datos_fiscales_cliente.rfc}</rfc_receptor>
                  <total xsi:type="xsd:string">#{@nota_credito.monto}</total>
                </folio>^

      cert_pem = OpenSSL::X509::Certificate.new File.read './public/certificado.cer'
      llave_pem = OpenSSL::PKey::RSA.new File.read './public/llave.pem'
      llave_password = "12345678a"

      #Se cancela 
      xml_cancelado = cancelar_CFDIs(username, password, rfc_emisor, folios, cert_pem, llave_pem, llave_password)
      #se extrae el acuse de cancelación del xml cancelado
      acuse = xml_cancelado.xpath("//acuse_cancelacion").text

      #Se crea un objeto de cloud para descargar los comprobantes
      gcloud = Google::Cloud.new "cfdis-196902","/home/daniel/Descargas/CFDIs-0fd739cbe697.json"
      storage=gcloud.storage
      bucket = storage.bucket "cfdis"
      #Se realizan las consultas para formar los directorios en cloud
      dir_negocio = current_user.negocio.nombre
      dir_sucursal = current_user.sucursal.nombre
      dir_cliente = @nota_credito.cliente.nombre_completo
      #Se separan obtiene el día, mes y año de la fecha de emisión del comprobante
      fecha_cancelacion =  DateTime.parse(Nokogiri::XML(acuse).xpath("//@Fecha").to_s)

      dir_dia = fecha_cancelacion.strftime("%d")
      dir_mes = fecha_cancelacion.strftime("%m")
      dir_anno = fecha_cancelacion.strftime("%Y")

      ac_nc_id = AcuseCancelacion.present? ? AcuseCancelacion.last.id + 1 : 1

      ruta_storage = "#{dir_negocio}/#{dir_sucursal}/#{dir_cliente}/#{dir_anno}/#{dir_mes}/#{dir_dia}/#{ac_nc_id}_ac_#{@nota_credito.tipo_factura}"
      #Se guarda el Acuse en la nube
      file = bucket.create_file StringIO.new(acuse.to_s), "#{ruta_storage}.xml"

      acuse = Nokogiri::XML(acuse)
      a = File.open("public/#{ac_nc_id}_ac_nc_#{@nota_credito.tipo_factura}", "w")
      a.write (acuse)
      a.close

      #El consecutivo para formar el folio del acuse de cancelación
      if @nota_credito.tipo_factura == "fv"
        #El consecutivo y folio del acuse de cancelación de la nota de crédito para las facturas de ventas
        consecutivo = 0
        if current_user.sucursal.acuse_cancelacions.where(comprobante: "nc_fv").last
          consecutivo = current_user.sucursal.acuse_cancelacions.where(comprobante: "nc_fv").last.consecutivo
          if consecutivo
            consecutivo += 1
          end
        else
          consecutivo = 1 
        end
        folio = current_user.sucursal.clave + "ACNCFV" + consecutivo.to_s
      elsif @nota_credito.tipo_factura == "fg"
        #El consecutivo y folio del acuse de cancelación de la nota de credito para las facturas globales
        consecutivo = 0
        if current_user.sucursal.acuse_cancelacions.where(comprobante: "nc_fg").last
          consecutivo = current_user.sucursal.acuse_cancelacions.where(comprobante: "nc_fg").last.consecutivo
          if consecutivo
            consecutivo += 1
          end
        else
          consecutivo = 1
        end
        folio = current_user.sucursal.clave + "ACNCFG" + consecutivo.to_s
      end

      #Se registra la cancelación de la nota de crédito
      tipo_comprobante = @nota_credito.tipo_factura = "fv" ? "nc_fv" : "nc_fg"
      @nota_credito_cancelada = AcuseCancelacion.new(folio: folio, comprobante: tipo_comprobante, consecutivo: consecutivo, fecha_cancelacion: fecha_cancelacion, ruta_storage: ruta_storage)#, monto: @venta.montoVenta)


      if @nota_credito_cancelada.save
        current_user.negocio.acuse_cancelacions << @nota_credito_cancelada
        current_user.sucursal.acuse_cancelacions << @nota_credito_cancelada 
        current_user.acuse_cancelacions << @nota_credito_cancelada
        
        #No hay relaciones entre la tabla Acuses y los direfrentes comprobantes, en lugar de ello solo hago referencia 
        if AcuseCancelacion.present?
          acuse_cancelacion_id = AcuseCancelacion.last.consecutivo
          if acuse_cancelacion_id
            acuse_cancelacion_id += 1
          end
        else
          acuse_cancelacion_id = 1 
        end
        @nota_credito.ref_acuse_cancelacion =  acuse_cancelacion_id
        @nota_credito.update( estado_nc: "Cancelada")      
      end

      plantilla_email("ac_nc_#{@factura.tipo_factura}")


      destinatario = params[:destinatario]
      comprobantes = {xml_Ac: "public/#{ac_id}_ac_nc_#{@nota_credito.tipo_factura}"}

      FacturasEmail.factura_email(destinatario, @mensaje, @asunto, comprobantes).deliver_now

      respond_to do |format| # Agregar mensajes después de las transacciones
        format.html { redirect_to nota_creditos_index_path, notice: "La nota de crédito con folio: #{@nota_credito.folio} ha sido cancelada y se ha enviado al email #{destinatario} exitosamente!" }
      end
    end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nota_credito
      @nota_credito = NotaCredito.find(params[:id])
    end
    def set_sucursales
      @sucursales = current_user.negocio.sucursals
    end
    def set_clientes
      #
      @nombreFiscalClientes = DatosFiscalesCliente.where(cliente_id: current_user.negocio.clientes.where(negocio_id: current_user.negocio.id))
      #@clientes = current_user.negocio.clientes
    end
    #Esta función sirve para optener la plantilla de email de los comprobantes, según sus estatus
    #Solo funciona para facturas de ventas y para el envío de los acuses de cancelación de las mismas.
    def plantilla_email(opc)
      require 'plantilla_email/plantilla_email.rb'
      #Las 4 opciones posibles son:
        #fv => factura de venta
        #ac_fv => acuse de cancelación de factura de venta (Las facturas globales quedan excluidas)
        #ac_nc => acuse de cancelación de nota de crédito
        #nc => nota de crédito
      mensaje = current_user.negocio.plantillas_emails.find_by(comprobante: opc).msg_email
      asunto = current_user.negocio.plantillas_emails.find_by(comprobante: opc).asunto_email
      cadena = PlantillaEmail::AsuntoMensaje.new
      
      if opc == "nc_fv" || opc == "nc_fg"
        cadena.nombCliente = @nota_credito.cliente.nombre_completo #if mensaje.include? "{{Nombre del cliente}}"
        
        cadena.fecha = @nota_credito.fecha_expedicion
        cadena.numero = @nota_credito.consecutivo
        cadena.folio = @nota_credito.folio
        cadena.total = @nota_credito.monto
        
        cadena.nombNegocio = @nota_credito.negocio.nombre 
        cadena.nombSucursal = @nota_credito.sucursal.nombre
        cadena.emailContacto = @nota_credito.sucursal.email
        cadena.telContacto = @nota_credito.sucursal.telefono

        @mensaje = cadena.reemplazar_texto(mensaje)
        @asunto = cadena.reemplazar_texto(asunto)

      #Se trata entonces de una cancelación de una nota de crédito y las cancelaciones de las notas de crédito tienen su propia plantilla
      elsif opc == "ac_nc_fg" || opc == "ac_nc_fv"
        cadena.nombCliente = @nota_credito.cliente.nombre_completo #if mensaje.include? "{{Nombre del cliente}}"
        
        #cadena.fecha = @nota_credito.fecha_expedicion#
        #cadena.numero = @nota_credito.consecutivo
        #cadena.folio = @nota_credito.folio
        #cadena.total = @nota_credito.monto
        
        cadena.nombNegocio = @nota_credito.negocio.nombre 
        cadena.nombSucursal = @nota_credito.sucursal.nombre
        cadena.emailContacto = @nota_credito.sucursal.email
        cadena.telContacto = @nota_credito.sucursal.telefono

        @mensaje = cadena.reemplazar_texto(mensaje)
        @asunto = cadena.reemplazar_texto(asunto)
      end

    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def nota_credito_params
      params.require(:nota_credito).permit(:folio, :fecha_expedicion, :monto_devolucion, :motivo, :user_id, :cliente_id, :sucursal_id, :negocio_id)
    end
end
