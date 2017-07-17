class ComprasController < ApplicationController
  before_action :set_compra, only: [:show, :edit, :update, :destroy, :actualizar]
  before_action :set_cajas, only: [:new, :create]
  before_action :set_compradores, only: [:index, :consulta_compras, :consulta_avanzada, :solo_sucursal, :consulta_compra_factura]
  before_action :set_sucursales, only: [:index, :consulta_compras, :consulta_avanzada, :solo_sucursal, :consulta_compra_factura]
  before_action :set_proveedores, only: [:index, :consulta_compras, :consulta_avanzada, :solo_sucursal, :actualizar, :consulta_compra_factura]
  before_action :set_categorias_cancelacion, only: [:index, :consulta_compras, :consulta_avanzada, :solo_sucursal, :edit, :update, :show, :consulta_compra_factura]

  #Se despliegan todas las compras del negocio o de la sucursal dependiendo los privilegios del usuario.
  def index
    @consulta = false
    @avanzada = false
    @rangoFechas = false
    @porFactura = false
    
    if can? :create, Negocio
      @compras = current_user.negocio.compras.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month)
    else
      @compras = current_user.sucursal.compras.where(created_at: Date.today.beginning_of_month..Date.today.end_of_month)
    end
  end

  #Se crea una nueva compra
  def new
    @proveedores = current_user.sucursal.proveedores
    @compra = Compra.new
    @proveedor = Proveedor.new
  end

  #Se muestran los detalles de una compra realizada. Para ello, se le pasan los items de compra
  #Su proveedor, sucursal y comprador. Todo esto se despliega en un modal de la vista.
  def show
    @items = @compra.detalle_compras
    @proveedor = @compra.proveedor.nombre
    @sucursal = @compra.sucursal.nombre
    @comprador = @compra.user.perfil ? @compra.user.perfil.nombre_completo : @compra.user.email

    if @compra.compra_cancelada
      @autorizacion = @compra.compra_cancelada.user.perfil ? @compra.compra_cancelada.user.perfil.nombre_completo  : @compra.compra_cancelada.user.email
      @fechaCancelacion = @compra.compra_cancelada.created_at
      @observacionesCancelacion = @compra.compra_cancelada.observaciones
      @categoriaCancelacion = @compra.compra_cancelada.cat_compra_cancelada.clave
    end
  end

  def consulta_compra_factura
    @consulta = true
    @porFactura = true
    @rangoFechas = false
    @avanzada = false
    if request.post?
      #la variable factura puede ser una factura o un ticket
      @factura = params[:factura_compra]
      if can? :create, Negocio
        @compras = current_user.negocio.compras.where(["folio_compra = ? or ticket_compra=?", @factura, @factura])
      else
      end
      
    end
  end

  
  #Este método devuelve un listado de compras en base a un rango de fechas. 
  def consulta_compras
    @consulta = true
    @porFactura = false
    @rangoFechas = true
    @avanzada = false
    if request.post?
      @fechaInicial = DateTime.parse(params[:fecha_inicial]).to_date
      @fechaFinal = DateTime.parse(params[:fecha_final]).to_date
      #Si tiene privilegios de Administrador, devolverá las compras de todo el negocio pero con el filtro respectivo
      #de lo contrario, sólo devolverá las compras de su propia sucursal con el filtro respectivo.
      if can? :create, Negocio
        @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day)
      else
        @compras = current_user.sucursal.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day)
      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end

    end
  end

  #Consulta avanzada devolverá una lista de compras en base en una serie de criterios que pueden ser combinables entre si.
  #Los criterios pueden ser: Rango de fechas, proveedor, comprador, status de la compra, 
  #sucursal (en el caso de administradores)
  def consulta_avanzada
    @consulta = true
    @porFactura = false
    @rangoFechas = false
    @avanzada = true
    if request.post?
      #obtiene la fecha inicial del rango de fechas
      @fechaInicial = DateTime.parse(params[:fecha_inicial_avanzado]).to_date

      #obtiene la fecha final del rango de fechas
      @fechaFinal = DateTime.parse(params[:fecha_final_avanzado]).to_date

      #id del perfil del comprador
      perfil_id = params[:perfil_id]

      proveedor_id = params[:proveedor_id]

      #variable de instancia que guardará el proveedor elegido (en caso de haber elegido uno al momento del filtrado)
      @proveedor = nil


      #variable de instancia que guardará al comprador elegido (en caso de haber elegido uno al momento del filtrado)
      @comprador = nil

      #Si el perfil no está vacío, significa que se escogió un perfil, por tanto, se busca el usuario
      #relacionado con este perfil y se asigna a la variable de instancia comprador
      unless perfil_id.empty?
        @comprador = Perfil.find(perfil_id).user
        @nombreComprador = @comprador.perfil.nombre_completo
      end

      unless proveedor_id.empty?
        @proveedor = Proveedor.find(proveedor_id)
      end

      #status de la compra: cancelada o activa (si es que se eligió una)
      @status = params[:status]

      if @status.eql?("Todas")
        @status = nil
      end

      #sucursal elegida de la compra (para usuarios con privilegios de administrador y es en caso de que haya elegido una)
      @suc = params[:suc_elegida]

      #Si la sucursal no está vacía, significa que se escogió una sucursal en la vista, por tanto, se busca la sucursal
      #en la base de datos que coincida con este id.
      unless @suc.empty?
        @sucursal = Sucursal.find(@suc)
      end
      
      #Resultados para usuario administrador o subadministrador
      if can? :create, Negocio

        #Si el único criterio elegido fue la sucursal.
        if @sucursal
          unless @comprador && @proveedor && @status
            @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, sucursal: @sucursal)
          end
        end

        #Si el único criterio elegido fue el comprador.
        if @comprador
          unless @sucursal && @proveedor && @status
            @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, user: @comprador)
          end
        end

        #Si el único criterio elegido fue el status
        if @status
          unless @comprador && @sucursal && @proveedor
            @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, status: @status)  
          end
        end

        #Si el único criterio elegido fue el proveedor
        if @proveedor
          unless @sucursal && @status && @comprador
            @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, proveedor: @proveedor)  
          end
        end

        #Si se filtra por sucursal y comprador
        if @sucursal && @comprador
          unless @status && @proveedor
            @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, sucursal: @sucursal, user: @comprador)  
          end
        end

        #Si se filtra por sucursal y status
        if @sucursal && @status
          unless @comprador && @proveedor
            @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, sucursal: @sucursal, status: @status)  
          end
        end

        #Si se filtra por sucursal y proveedor
        if @sucursal && @proveedor
          unless @status && @usuario
            @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, sucursal: @sucursal, proveedor: @proveedor)  
          end
        end
        
        #Si se filtra por comprador y status
        if @comprador && @status
          unless @sucursal && @proveedor
            @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, user: @comprador, status: @status)  
          end
        end

        #Si se filtra por comprador y proveedor
        if @comprador && @proveedor
          unless @sucursal && @status
            @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, user: @comprador, proveedor: @proveedor)              
          end
        end

        #Si se filtra por status y proveedor
        if @status && @proveedor
          unless @sucursal && @comprador
            @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, status: @status, proveedor: @proveedor)              
          end
        end

        #Si se filtra por sucursal, comprador y status
        if @sucursal && @comprador && @status
          unless @proveedor
            @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, sucursal: @sucursal, user: @comprador, status: @status)              
          end
        end

        #Si se filtra por sucursal, status, proveedor
        if @sucursal && @status && @proveedor
          unless @comprador
            @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, sucursal: @sucursal, status: @status, proveedor: @proveedor)
          end
        end

        #Si se filtra por sucursal, proveedor y comprador
        if @sucursal && @proveedor && @comprador
          unless @status
            @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, sucursal: @sucursal, proveedor: @proveedor, user: @comprador)              
          end
        end

        #Si se filtra por comprador, status y proveedor
        if @comprador && @status && @proveedor
          unless @sucursal
            @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, comprador: @comprador, status: @status, proveedor: @proveedor)              
          end
        end

        #Cuando se elige una opción en cada uno de los criterios de filtrado: comprador, status, proveedor, sucursal
        if @comprador && @status && @proveedor && @sucursal
          @compras = current_user.negocio.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, comprador: @comprador, status: @status, proveedor: @proveedor, sucursal:@sucursal)              
        end
      #################################################################################################################
      #Si el usuario no es un administrador o subadministrador
      else
        
        #Si el único criterio elegido fue el comprador.
        if @comprador
          unless @proveedor && @status
            @compras = current_user.sucursal.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, user: @comprador)
          end
        end

        #Si el único criterio elegido fue el status
        if @status
          unless @comprador && @proveedor
            @compras = current_user.sucursal.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, status: @status)  
          end
        end

        #Si el único criterio elegido fue el proveedor
        if @proveedor
          unless @status && @comprador
            @compras = current_user.sucursal.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, proveedor: @proveedor)  
          end
        end
        
        #Si se filtra por comprador y status
        if @comprador && @status
          unless @proveedor
            @compras = current_user.sucursal.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, user: @comprador, status: @status)  
          end
        end

        #Si se filtra por comprador y proveedor
        if @comprador && @proveedor
          unless @status
            @compras = current_user.sucursal.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, user: @comprador, proveedor: @proveedor)              
          end
        end

        #Si se filtra por status y proveedor
        if @status && @proveedor
          unless @comprador
            @compras = current_user.sucursal.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, status: @status, proveedor: @proveedor)              
          end
        end

        #Si se filtra por comprador, status y proveedor
        if @comprador && @status && @proveedor
          @compras = current_user.sucursal.compras.where(fecha: @fechaInicial.beginning_of_day..@fechaFinal.end_of_day, comprador: @comprador, status: @status, proveedor: @proveedor)              
        end

      end

      respond_to do |format|
        format.html
        format.json
        format.js
      end
    end
  end

  #Los administradores tendrán disponible esta funcionalidad. Dado que a los administradores se les muestran las compras
  #de todas las sucursales, puede resultarles deseable que se les muestren solo las compras hechas en su propia sucursal
  #(que generalmente será la matriz)
  def solo_sucursal
    @consulta = false
    @rangoFechas = false
    @avanzada = false
    @porFactura = false
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
    @compra.status = "Activa"
    origen_recurso = ""
    monto_compra = compra_params[:monto_compra].to_f
    tipo_pago = compra_params[:tipo_pago]
    forma_pago = compra_params[:forma_pago]
    @cajaVenta = nil
    @gasto = nil
    @pagoProveedor = nil
    @movimientoCaja = nil
    @cajaChica = nil

    #TODO discriminar la forma de pago. En la caja solo debe ser cargadas las compras en efectivo


    respond_to do |format|

      #Si la forma de pago seleccionada fue "Contado", entonces se procede a hacer los registros
      #para registrar el gasto; haciendo también las operaciones necesarias con respecto al
      #origen del recurso.
      if tipo_pago.eql?("Contado")

        @categoriaGasto = current_user.negocio.categoria_gastos.where("nombreCategoria = ?", "Compras").take

        origen_recurso = params[:select_origen_recurso]

        #Si se cumple esta condición, significa que el recurso para la compra, provendrá de alguna de las cajas 
        #de venta que tiene la sucursal. La cadena contiene el id de la caja de venta seleccionada.
        if origen_recurso.include? "caja_venta"
          tamano_cadena_origen = origen_recurso.length

          #aquí extraigo el id de la caja de venta contenido en la cadena de texto
          #el número "11" corresponde a la cantidad de caracteres de la cadena "caja_venta_"
          id_caja_sucursal = origen_recurso[11..tamano_cadena_origen]

          #En base al id extraido de la cadena, busco la Caja de Venta en la base de datos
          @cajaVenta = CajaSucursal.find(id_caja_sucursal)

          #Verifico que la caja tenga el saldo necesario para realizar la operación de compra.
          if @cajaVenta.saldo >= monto_compra
            @gasto = Gasto.new(:monto=>monto_compra, :concepto=>"Compra de mercancía", :tipo=>"compra")
            
            #creación y relación del registro de pago de la compra al proveedor indicado
            @pagoProveedor = PagoProveedor.new(:monto=>monto_compra, :compra=>@compra, :gasto=>@gasto, :proveedor=>@compra.proveedor, :user=>current_user, :sucursal=>current_user.sucursal, :negocio=>current_user.negocio, :statusPago=>"Liquidación de compra")

            #relaciones del registro de gasto
            @categoriaGasto.gastos << @gasto
            @cajaVenta.gastos << @gasto
            current_user.gastos << @gasto
            current_user.sucursal.gastos << @gasto
            current_user.negocio.gastos << @gasto

            #Se actualiza el saldo de la caja de venta
            saldo = @cajaVenta.saldo - monto_compra
            @cajaVenta.saldo = saldo

            #Se registra el movimiento de caja de venta. En este caso, es un movimiento de salida
            @movimientoCaja = MovimientoCajaSucursal.new(:salida=>monto_compra, :caja_sucursal=>@cajaVenta)
            current_user.movimiento_caja_sucursals << @movimientoCaja
            current_user.sucursal.movimiento_caja_sucursals << @movimientoCaja
            current_user.negocio.movimiento_caja_sucursals << @movimientoCaja

            if @compra.valid?
              if @compra.save && @cajaVenta.save && @gasto.save && @pagoProveedor.save && @movimientoCaja.save
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
                  
                  detalleCompra = @compra.detalle_compras.build(:cantidad_comprada=>cantidad, :precio_compra=>precio, :importe=>importe, :status=>"Activa")
                  entradaAlmacen = @compra.entrada_almacens.build(:cantidad=>cantidad, :fecha=>fecha, :isEntradaInicial=>false)
                  bd_articulo = Articulo.where("clave=? and sucursal_id=?" , codigo, current_user.sucursal.id).take
                  bd_articulo.detalle_compras << detalleCompra
                  bd_articulo.entrada_almacens << entradaAlmacen

                  existencia = bd_articulo.existencia

                  nuevaExistencia = existencia + entradaAlmacen.cantidad

                  bd_articulo.existencia = nuevaExistencia

                  bd_articulo.save


                }

                current_user.compras << @compra
                current_user.negocio.compras << @compra
                current_user.sucursal.compras << @compra
                format.html { redirect_to compras_new_path, notice: 'La compra se registró existosamente' }
                format.json { render :new, status: :created, location: @compra }
                #format.json { head :no_content}
                #format.js
              else
                format.html { render :new }
                format.json { render json: @compra.errors, status: :unprocessable_entity }
                flash[:notice] = "Hubo un error al momento de guardar la compra"
              end
            else
              format.html { render :new }
              format.json { render json: @compra.errors, status: :unprocessable_entity }
            end  

          else
            format.html { render :new }
            format.json { render json: @compra.errors, status: :unprocessable_entity }
            flash[:notice] = "No hay saldo suficiente en la caja #{@cajaVenta.nombre} para hacer la compra. Compra no realizada"
          end

        end

        #Si se cumple esta condición, significa que el recurso provendrá de la caja chica que tiene la sucursal.
        if origen_recurso.include? "caja_chica"
          #Verifica si existen registros de caja chica para esta sucursal
          if current_user.sucursal.caja_chicas
            #Se obtiene el saldo actual de la caja chica haciendo una comparación de sumatorias entre las entradas
            #y las salidas de caja chica.
            entradas = CajaChica.sum(:entrada, :conditions=>["sucursal_id=?", current_user.sucursal.id])
            salidas = CajaChica.sum(:salida, :conditions=>["sucursal_id=?", current_user.sucursal.id])
            @saldoCajaChica = entradas - salidas


            if @saldoCajaChica >= monto_compra

              saldo_en_caja_chica = @saldoCajaChica

              @gasto = Gasto.new(:monto=>monto_compra, :concepto=>"Compra de mercancía", :tipo=>"compra")

              #creación y relación del registro de pago de la compra al proveedor indicado
              @pagoProveedor = PagoProveedor.new(:monto=>monto_compra, :compra=>@compra, :gasto=>@gasto, :proveedor=>@compra.proveedor, :user=>current_user, :sucursal=>current_user.sucursal, :negocio=>current_user.negocio, :statusPago=>"Liquidación de compra")
              
              #relaciones del registro de gasto
              @categoriaGasto.gastos << @gasto
              current_user.gastos << @gasto
              current_user.sucursal.gastos << @gasto
              current_user.negocio.gastos << @gasto

              #Se hace un registro en caja chica y se relaciona con el gasto
              @cajaChica = CajaChica.new(:concepto=>"Compra de mercancía", :salida=>monto_compra)
              @cajaChica.gasto = @gasto

              #Se hacen las relaciones de pertenencia para la caja chica.
              current_user.caja_chicas << @cajaChica
              current_user.sucursal.caja_chicas << @cajaChica
              current_user.negocio.caja_chicas << @cajaChica

              if @compra.valid?
                if @compra.save && @cajaChica.save && @gasto.save && @pagoProveedor.save
                  articulos = compra_params[:articulos]
                  fecha = DateTime.parse(compra_params[:fecha]).to_date
                  tipo_pago = compra_params[:tipo_pago]
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
                    
                    detalleCompra = @compra.detalle_compras.build(:cantidad_comprada=>cantidad, :precio_compra=>precio, :importe=>importe, :status=>"Activa")
                    entradaAlmacen = @compra.entrada_almacens.build(:cantidad=>cantidad, :fecha=>fecha, :isEntradaInicial=>false)
                    bd_articulo = Articulo.where("clave=? and sucursal_id=?" , codigo, current_user.sucursal.id).take
                    bd_articulo.detalle_compras << detalleCompra
                    bd_articulo.entrada_almacens << entradaAlmacen

                    existencia = bd_articulo.existencia

                    nuevaExistencia = existencia + entradaAlmacen.cantidad

                    bd_articulo.existencia = nuevaExistencia

                    bd_articulo.save


                  }

                  current_user.compras << @compra
                  current_user.negocio.compras << @compra
                  current_user.sucursal.compras << @compra
                  format.html { redirect_to compras_new_path, notice: 'La compra se registró existosamente' }
                  format.json { render :new, status: :created, location: @compra }
                  #format.json { head :no_content}
                  #format.js
                else
                  format.html { render :new }
                  format.json { render json: @compra.errors, status: :unprocessable_entity }
                  flash[:notice] = "Hubo un error al momento de guardar la compra"
                end
              else
                format.html { render :new }
                format.json { render json: @compra.errors, status: :unprocessable_entity }
              end  


            else
              format.html { render :new }
              format.json { render json: @compra.errors, status: :unprocessable_entity }
              flash[:notice] = "No hay saldo suficiente en la caja chica para hacer la compra. Compra no realizada"
            end
          end
        end
        
      elsif tipo_pago.eql?("Credito") #Si la compra es a crédito
        
        fecha_limite = DateTime.parse(compra_params[:fecha_limite_pago]).to_date
        @pagoPendiente = PagoPendiente.new(:fecha_vencimiento=>fecha_limite, :saldo=>monto_compra, :compra=>@compra, :proveedor=>@compra.proveedor, :sucursal=>current_user.sucursal, :negocio=>current_user.negocio)
        if @compra.valid?
          if @compra.save && @pagoPendiente.save
            articulos = compra_params[:articulos]
            fecha = DateTime.parse(compra_params[:fecha]).to_date
            tipo_pago = compra_params[:tipo_pago]
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
              
              detalleCompra = @compra.detalle_compras.build(:cantidad_comprada=>cantidad, :precio_compra=>precio, :importe=>importe, :status=>"Activa")
              entradaAlmacen = @compra.entrada_almacens.build(:cantidad=>cantidad, :fecha=>fecha, :isEntradaInicial=>false)
              bd_articulo = Articulo.where("clave=? and sucursal_id=?" , codigo, current_user.sucursal.id).take
              bd_articulo.detalle_compras << detalleCompra
              bd_articulo.entrada_almacens << entradaAlmacen

              existencia = bd_articulo.existencia

              nuevaExistencia = existencia + entradaAlmacen.cantidad

              bd_articulo.existencia = nuevaExistencia

              bd_articulo.save


            }

            current_user.compras << @compra
            current_user.negocio.compras << @compra
            current_user.sucursal.compras << @compra
            format.html { redirect_to compras_new_path, notice: 'La compra se registró existosamente' }
            format.json { render :new, status: :created, location: @compra }
            #format.json { head :no_content}
            #format.js
          else
            format.html { render :new }
            format.json { render json: @compra.errors, status: :unprocessable_entity }
          end
        else
          format.html { render :new }
          format.json { render json: @compra.errors, status: :unprocessable_entity }
        end
        

      end

    end

  end

  def edit
    @items = @compra.detalle_compras
  end

  def actualizar
    #if request.get?
    #  @compra = Compra.find(params[:compra])
    #end
    
    #Si la petición ha venido por el método post, entonces se procede a la actualización de la compra.
    if request.patch?
      @monto_anterior = @compra.monto_compra
      respond_to do |format|
        if @compra.update(compra_params)
          #Se borran los destalles de compra y entradas de almacen relacionados con la compra.
          @compra.detalle_compras.each do |detalle|
            #antes de borrar el detalle de compra, se obtiene la cantidad que fue comprada para descontarla del
            #inventario del articulo
            cantidadComprada = detalle.cantidad_comprada
            existenciaActual = detalle.articulo.existencia
            nuevaExistenciaArticulo = existenciaActual - cantidadComprada

            #Se eliminan todas las existencias del articulo que estén relacionadas con la compra.
            #Más adelante se actualizará la existencia del articulo en base a los datos editados.
            detalle.articulo.existencia = nuevaExistenciaArticulo

            detalle.save

            #Una vez obtenidos los datos necesarios, se destruye el detalle de compra.
            #Posteriormente se añadiran los nuevos detalles en base a la edición del usuario.
            detalle.destroy

          end

          #Así mismo, este bucle destruye todas las entradas de almacén de esta compra.
          @compra.entrada_almacens.each do |entrada_almacen|
            entrada_almacen.destroy
          end

          
          articulos = compra_params[:articulos]
          fecha = DateTime.parse(compra_params[:fecha]).to_date
          razon_edicion = params[:compra_razon]

          #Ahora se crea un registro en el historia de ediciones de compra
          historial = HistorialEdicionesCompra.create(:monto_anterior=>@monto_anterior, :razon_edicion=>razon_edicion[:edicion])
          @compra.historial_ediciones_compras << historial
          current_user.negocio.historial_ediciones_compras << historial
          current_user.sucursal.historial_ediciones_compras << historial
          current_user.historial_ediciones_compras << historial

          

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
                
            detalleCompra = @compra.detalle_compras.build(:cantidad_comprada=>cantidad, :precio_compra=>precio, :importe=>importe, :status=>"Activa")
            entradaAlmacen = @compra.entrada_almacens.build(:cantidad=>cantidad, :fecha=>fecha, :isEntradaInicial=>false)
            bd_articulo = Articulo.where("clave=? and sucursal_id=?" , codigo, current_user.sucursal.id).take

            #Se relaciona el artículo comprado con la compra
            bd_articulo.detalle_compras << detalleCompra

            #Se relaciona una entrada al almacén con un artículo 
            bd_articulo.entrada_almacens << entradaAlmacen

            #obtiene la existencia actual del artículo para actualizarla posteriormente añadiendole las nuevas
            #compras
            existencia_actual = bd_articulo.existencia

            #La nueva existencia se calcula en base a la existencia actual y lo encontrado en la entrada de almacén de 
            #esta compra.
            nuevaExistencia = existencia_actual + entradaAlmacen.cantidad

            #Se actualiza también el precio de compra del artículo. TODO hacer un historial de precios de compra por artículo.
            bd_articulo.precioCompra = detalleCompra.precio_compra

            #Se actualiza la nueva existencia y se guarda el artículo 
            bd_articulo.existencia = nuevaExistencia
            bd_articulo.save
          }
            
          format.html { redirect_to compras_path, notice: 'Compra actualizada' }
          format.json { render :index, status: :created, location: @compra }
        else
          format.html { render :index }
          format.json { render json: @compra.errors, status: :unprocessable_entity }
        end
      end

    end
  end

  #El método update de compras se utiliza para cancelar una compra completamente.
  def update
    respond_to do |format|
      categoria = params[:cat_cancelacion]
      cat_compra_cancelada = CatCompraCancelada.find(categoria)
      compra = params[:compra]
      observaciones = compra[:observaciones]
      @items = @compra.detalle_compras
      
      if @compra.update(:observaciones => observaciones, :status => "Cancelada")
        
        CompraCancelada.create(:compra=>@compra, :cat_compra_cancelada=>cat_compra_cancelada, :user=>current_user, :observaciones=>observaciones, :negocio=>current_user.negocio, :sucursal=>current_user.sucursal)
        @compra.detalle_compras.each do |itemCompra|
          CompraArticulosDevuelto.create(:articulo => itemCompra.articulo, :detalle_compra => itemCompra, :compra => @compra, :cat_compra_cancelada=>cat_compra_cancelada, :user=>current_user, :observaciones=>observaciones, :negocio=>@compra.negocio, :sucursal=>@compra.sucursal, :cantidad_devuelta=>itemCompra.cantidad_comprada)
          articulo = itemCompra.articulo
          articulo.existencia = articulo.existencia - itemCompra.cantidad_comprada
          articulo.save

          itemCompra.status = "Cancelada"
          itemCompra.save

          entradasAlmacen = EntradaAlmacen.where(:compra=>@compra)
          
          entradasAlmacen.each do |entradaAlmacen|
            entradaAlmacen.destroy
          end

          #Se eliminan todos los pagos y egresos que hayan sido registrados para esta compra.
          if @compra.pago_proveedores
            caja_chica = nil
            caja_sucursal = nil
            @compra.pago_proveedores.each do |pago|
              gasto = pago.gasto
              if gasto.caja_chica
                caja_chica = gasto.caja_chica
                caja_chica.destroy
              end
              if gasto.movimiento_caja_sucursals
                movimiento_caja_sucursal = gasto.movimiento_caja_sucursals
                movimiento_caja_sucursal.destroy
              end
              gasto.destroy
              pago.destroy
            end
          end

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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_compra
      @compra = Compra.find(params[:id])
    end

    def set_cajas
      @cajas = current_user.sucursal.caja_sucursals
    end


    def set_compradores
      @compradores = []
      if can? :create, Negocio
        current_user.negocio.users.each do |comprador|
          #Llena un array con todos los compradores del negocio
          #(usuarios del negocio que pueden hacer una compra)
          #Siempre y cuando no sean auxiliares o almacenistas o compradors pues no tienen autorización para comprar
          if comprador.role != "auxiliar" || comprador.role != "almacenista" || comprador.role != "comprador"
            @compradores.push(comprador.perfil)
          end
        end
      else
        current_user.sucursal.users.each do |comprador|
          #Llena un array con todos los compradores de la sucursal 
          #(usuarios de la sucursal que pueden hacer una compra)
          #Siempre y cuando no sean auxiliares o almacenistas o compradors pues no tiene autorización para comprar
          if comprador.role != "auxiliar" || comprador.role != "almacenista" || comprador.role != "comprador"
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
      params.require(:compra).permit(:fecha, :tipo_pago, :plazo_pago, :folio_compra, :proveedor_id, :forma_pago, :articulos, :monto_compra, :ticket_compra, :compra_razon, :fecha_limite_pago, :select_origen_recurso)
    end

     #Asigna lista de categorias de devolucion de compras
    def set_categorias_cancelacion
        @categorias_cancelacion = current_user.negocio.cat_compra_canceladas
    end

end
