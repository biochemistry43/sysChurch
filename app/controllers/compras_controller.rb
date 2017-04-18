class ComprasController < ApplicationController
  before_action :set_compra, only: [:edit, :update, :destroy]

  def index
    if can? :update, Negocio
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def compra_params
      params.require(:compra).permit(:fecha, :tipo_pago, :plazo_pago, :folio_compra, :proveedor_id, :forma_pago, :articulos, :monto_compra)
    end

end
