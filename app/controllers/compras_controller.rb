class ComprasController < ApplicationController
  before_action :set_compra, only: [:show, :edit, :update, :destroy]
  before_action :set_compradores, only: [:index, :consulta_compras, :consulta_avanzada, :solo_sucursal]
  before_action :set_sucursales, only: [:index, :consulta_compras, :consulta_avanzada, :solo_sucursal]
  before_action :set_proveedores, only: [:index, :consulta_compras, :consulta_avanzada, :solo_sucursal]

  def index
    @consulta = false
    @avanzada = false
    if can? :create, Negocio
      @compras = current_user.negocio.compras
    else
      @compras = current_user.sucursal.compras
    end
  end

  def new
    @proveedores = current_user.sucursal.proveedores
    @compra = Compra.new
    @proveedor = Proveedor.new
  end

  def show
  end

  def consulta_compras
    @consulta = true
    @avanzada = false
    if request.post?
      fechaInicial = DateTime.parse(params[:fecha_inicial]).to_date
      fechaFinal = DateTime.parse(params[:fecha_final]).to_date
      if can? :create, Negocio
        @compras = current_user.negocio.compras.where(fecha: fechaInicial..fechaFinal)
      else
        @compras = current_user.sucursal.compras.where(fecha: fechaInicial..fechaFinal)
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
              @compras = current_user.negocio.compras.where(fechaVenta: @fechaInicial..@fechaFinal, user: @cajero, status: @status, sucursal: @sucursal)
            else
              @compras = current_user.negocio.compras.where(fechaVenta: @fechaInicial..@fechaFinal, user: @cajero, sucursal: @sucursal)  
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
      @compras = current_user.sucursal.compras
      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end

  def create
    @compra = Compra.new(compra_params)
    @proveedores = current_user.sucursal.proveedores
     
    respond_to do |format|
      if @compra.valid?
        if @compra.save
          articulos = compra_params[:articulos]
          fecha = DateTime.parse(compra_params[:fecha]).to_date

          hashArticulos = JSON.parse(articulos.gsub('\"', '"'))

          codigo = ""
          cantidad = 0
          precio = 0
          importe = 0
          existencia = 0
          nuevaExistencia = 0


          hashArticulos.collect { |articulo|

            codigo = articulo["codigo"]
            precio = articulo["precio"]
            cantidad = articulo["cantidad"]
            importe = articulo["importe"]
            
            detalleCompra = @compra.detalle_compras.build(:cantidad_comprada=>cantidad, :precio_compra=>precio, :importe=>importe)
            entradaAlmacen = @compra.entrada_almacens.build(:cantidad=>cantidad, :fecha=>fecha, :isEntradaInicial=>false)
            articulo = Articulo.where("clave=? and sucursal_id=?" , codigo, current_user.sucursal.id).take
            articulo.detalle_compras << detalleCompra
            articulo.entrada_almacens << entradaAlmacen

            existencia = articulo.existencia

            nuevaExistencia = existencia + entradaAlmacen.cantidad

            articulo[:existencia] = nuevaExistencia

            articulo.save


          }

          current_user.compras << @compra
          current_user.negocio.compras << @compra
          current_user.sucursal.compras << @compra
          format.html { redirect_to compras_new_path, notice: 'La compra se registró existosamente' }
          format.json { render :new, status: :created, location: @compra }
          #format.json { head :no_content}
          #format.js
        else
          #format.html { render :new }
          #format.json { render json: @articulo.errors, status: :unprocessable_entity }
          #format.json {render json: @compra.errors.full_messages, status: :unprocessable_entity}
          #format.js {render :new}
        end
      else
        format.html { render :new }
        format.json { render json: @compra.errors, status: :unprocessable_entity }
        #format.js { render :new }
        #format.json {render json: @compra.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_compra
      @compra = Compra.find(params[:id])
    end

    def set_compradores
      @compradores = []
      if can? :create, Negocio
        current_user.negocio.users.each do |comprador|
          #Llena un array con todos los compradores del negocio
          #(usuarios del negocio que pueden hacer una compra)
          #Siempre y cuando no sean auxiliares o almacenistas o cajeros pues no tienen autorización para comprar
          if comprador.role != "auxiliar" || comprador.role != "almacenista" || comprador.role != "cajero"
            @compradores.push(comprador.perfil)
          end
        end
      else
        current_user.sucursal.users.each do |comprador|
          #Llena un array con todos los compradores de la sucursal 
          #(usuarios de la sucursal que pueden hacer una compra)
          #Siempre y cuando no sean auxiliares o almacenistas o cajeros pues no tiene autorización para comprar
          if comprador.role != "auxiliar" || comprador.role != "almacenista" || comprador.role != "cajero"
            @compradores.push(comprador.perfil)
          end
        end
      end
    end

    def set_proveedores
      @proveedores = current_user.sucursal.proveedores
    end

    def set_sucursales
      @sucursales = current_user.negocio.sucursals
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def compra_params
      params.require(:compra).permit(:fecha, :tipo_pago, :plazo_pago, :folio_compra, :proveedor_id, :forma_pago, :articulos, :monto_compra, :ticket_compra)
    end

end
