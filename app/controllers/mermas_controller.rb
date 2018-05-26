class MermasController < ApplicationController

  before_action :set_merma, only: [:show, :edit, :update, :destroy]
  
  def index
    @mermas = current_user.sucursal.mermas
  end

  def show
  end

  def new
    @merma = Merma.new
    @articulo = Articulo.find(params[:id])
    @categorias = current_user.negocio.categoria_mermas
  end

  def create
    @merma = Merma.new(merma_params)
    merma = params[:merma]
    @articulo = Articulo.find(merma[:articulo_id])
    respond_to do |format|
      ActiveRecord::Base.transaction do
        if @merma.save
          current_user.negocio.mermas << @merma
          current_user.sucursal.mermas << @merma
          current_user.mermas << @merma
          @articulo.mermas << @merma
          format.json { head :no_content }
          format.js
        else
          format.json { render json: @merma.errors.full_messages, status: :unprocessable_entity }
          format.js { render :new }
        end
      end
    end
  end

  #Por ahora estará inactivo
  #TODO: Habilitar la posibilidad de editar una merma.
  def edit
  end

  #Por ahora estará inactivo
  #TODO: Habilitar la posibiidad de editar una merma
  def update
  end

  #Por ahora estará inactivo
  #TODO: Habilitar la posibilidad de borrar una merma
  def destroy
  end

  private

    def merma_params
      params.require(:merma).permit(:motivo_baja, :cantidad_merma, :categoria_merma_id)
    end

    def set_merma
      @merma = Merma.find(params[:id])
    end
end
