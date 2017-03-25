class ComprasController < ApplicationController
  before_action :set_compra, only: [:edit, :update, :destroy]

  def index
  end

  def new
    @proveedores = current_user.sucursal.proveedores
    @compra = Compra.new
  end

  def show
  end

  def create
    @compra = Compra.new(compra_params)
    @proveedores = current_user.sucursal.proveedores
    respond_to do |format|
      if @compra.valid?
        if @compra.save
          current_user.compras << @compra
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
      params.require(:compra).permit(:fecha, :tipo_pago, :plazo_pago, :folio_compra, :proveedor_id, :forma_pago)
    end

end
