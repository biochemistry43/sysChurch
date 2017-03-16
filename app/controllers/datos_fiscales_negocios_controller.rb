class DatosFiscalesNegociosController < ApplicationController
  before_action :set_datos_fiscales_negocio, only: [:show, :edit, :update, :destroy]

  def index
  end

  def show
  end

  def new
  end

  def create
  end

  def update
    respond_to do |format|
      if @datosFiscales.update(datos_fiscales_negocio_params)
        format.html { redirect_to negocio_path(@datosFiscales.negocio), notice: 'Los datos fiscales del negocio fueron actualizados' }
      else
        format.html { redirect_to :back, notice: 'Error al actualizar los datos fiscales' }
      end
    end
  end

  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_datos_fiscales_negocio
      @datosFiscales = DatosFiscalesNegocio.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def datos_fiscales_negocio_params
      params.require(:datos_fiscales_negocio).permit(:nombreFiscal, :direccionFiscal, :rfc)
    end

end
