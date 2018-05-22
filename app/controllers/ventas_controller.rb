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
      
      ActiveRecord::Base.transaction do
        if @venta.update!(:observaciones => observaciones, :status => "Cancelada")
        
          #Se obtiene el movimiento de caja de sucursal, de la venta que se quiere cancelar
          movimiento_caja = @venta.movimiento_caja_sucursal

          #Si el pago de la venta se realizó en efectivo, entonces se añade el monto de la venta al saldo de la caja
          if movimiento_caja.tipo_pago.eql?("efectivo")
            caja_sucursal = @venta.caja_sucursal
            saldo = caja_sucursal.saldo
            saldoActualizado = saldo - @venta.montoVenta
            caja_sucursal.saldo = saldoActualizado 
            caja_sucursal.save!
          end

          #Se elimina el movimiento de caja relacionado con la venta
          movimiento_caja.destroy!

          #Por cada item de venta, se crea un registro de venta cancelada.
          @venta.item_ventas.each do |itemVenta|
            ventaCancelada = VentaCancelada.create(:articulo => itemVenta.articulo, :item_venta => itemVenta, :venta => @venta, :cat_venta_cancelada=>cat_venta_cancelada, :user=>current_user, :observaciones=>observaciones, :negocio=>@venta.negocio, :sucursal=>@venta.sucursal, :cantidad_devuelta=>itemVenta.cantidad, :monto=>itemVenta.monto)
            itemVenta.status = "Con devoluciones"
            
            
            
            #Se devuelve al inventario, los productos de la venta cancelada.
            itemVenta.articulo.existencia = itemVenta.cantidad + itemVenta.articulo.existencia
            itemVenta.articulo.save!
            itemVenta.save!
          end

          


          format.json { head :no_content}
          format.js
        else
          format.json {render json: @venta.errors.full_messages, status: :unprocessable_entity}
          format.js {render :edit}
        end

      end#Fin de la transacción
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

end
