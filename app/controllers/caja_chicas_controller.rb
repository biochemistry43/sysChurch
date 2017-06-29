class CajaChicasController < ApplicationController
  before_action :set_caja_chica, only: [:edit, :update, :destroy]

  def index
    @movimientos_caja = current_user.sucursal.caja_chicas
    if current_user.sucursal.caja_chicas.count > 0
      last = current_user.sucursal.caja_chicas.last
      @saldo = last.saldo
    else
      @saldo = 0.0
    end
    @caja_chicas = current_user.sucursal.caja_chicas
  end

  def new
    @caja_chica = CajaChica.new
  end 

  def show
  end

  def create
    @caja_chica = CajaChica.new(caja_chica_params)
    
    #actualizando el saldo de la caja chica
    last = nil
    if current_user.sucursal.caja_chicas.count > 0
      last = current_user.sucursal.caja_chicas.last
      saldoActual = last.saldo
      saldoActualizado = caja_chica_params[:entrada].to_f + saldoActual
      @caja_chica.saldo = saldoActualizado
    else
      @caja_chica.saldo = caja_chica_params[:entrada].to_f
    end

    #aplicando un concepto genérico
    @caja_chica.concepto = "Reposicion de caja"

    #Relacionando el registro de caja chica con el usuario, negocio y sucursal
    current_user.caja_chicas << @caja_chica
    current_user.negocio.caja_chicas << @caja_chica
    current_user.sucursal.caja_chicas << @caja_chica

    

    respond_to do |format|
      if @caja_chica.save
      
        format.json { head :no_content}
        format.js
      else
        format.json {render json: @caja_chica.errors.full_messages, status: :unprocessable_entity}
        format.js {render :new} 
      end
    end

  end

  def edit
  end

  def update
    

    respond_to do |format|
      if @caja_chica.update(caja_chica_params)
        format.json { head :no_content}
        format.js
      else
        format.json {render json: @caja_chica.errors.full_messages, status: :unprocessable_entity}
        format.js {render :edit}
      end
    end
  end

  def destroy
    @caja_chica.destroy
    respond_to do |format|
      format.js
      format.json { head :no_content }
    end
  end

  private

    def set_caja_chica
      @caja_chica = CajaChica.find(params[:id])
    end

    def caja_chica_params
      params.require(:caja_chica).permit(:entrada)
    end

end
