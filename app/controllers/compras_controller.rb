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
    def articulo_params
      params.require(:articulo).permit(:fecha, :tipo_pago, :plazo_pago, :folio_compra, :proveedor_id, :forma_pago)
    end

end
