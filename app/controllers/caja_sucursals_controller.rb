class CajaSucursalsController < ApplicationController
  before_action :set_caja_sucursal, only: [:show, :edit, :update, :destroy]
  before_action :set_usuarios, only: [:new, :edit, :update, :destroy]

  # GET /caja_sucursals
  # GET /caja_sucursals.json
  def index
    @caja_sucursals = current_user.sucursal.caja_sucursals
  end

  # GET /caja_sucursals/1
  # GET /caja_sucursals/1.json
  def show
  end

  # GET /caja_sucursals/new
  def new
    @caja_sucursal = CajaSucursal.new
  end

  # GET /caja_sucursals/1/edit
  def edit
  end

  # POST /caja_sucursals
  # POST /caja_sucursals.json
  def create
    @caja_sucursal = CajaSucursal.new(caja_sucursal_params)
    user = Perfil.find(params[:perfil_id]).user
    @caja_sucursal.user_id = user.id
    respond_to do |format|
      if @caja_sucursal.save

        #format.html { redirect_to @caja_sucursal, notice: 'Se creo una caja para esta sucursal.' }
        #format.json { render :show, status: :created, location: @caja_sucursal }
        current_user.sucursal.caja_sucursals << @caja_sucursal
        current_user.negocio.caja_sucursals << @caja_sucursal
        format.json { head :no_content}
        format.js
      else
        format.json {render json: @caja_sucursal.errors.full_messages, status: :unprocessable_entity}
        format.js {render :new}
        #format.html { render :new }
        #format.json { render json: @caja_sucursal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /caja_sucursals/1
  # PATCH/PUT /caja_sucursals/1.json
  def update
    respond_to do |format|
      
      if @caja_sucursal.update(caja_sucursal_params)
        user = Perfil.find(params[:perfil_id]).user
        @caja_sucursal.user_id = user.id
        @caja_sucursal.save
        #format.html { redirect_to @caja_sucursal, notice: 'Caja sucursal was successfully updated.' }
        #format.json { render :show, status: :ok, location: @caja_sucursal }
        format.json { head :no_content}
        format.js
      else
        format.json {render json: @caja_sucursal.errors.full_messages, status: :unprocessable_entity}
        format.js {render :new}
      end
    end
  end

  # DELETE /caja_sucursals/1
  # DELETE /caja_sucursals/1.json
  def destroy
    @caja_sucursal.destroy
    respond_to do |format|
      #format.html { redirect_to caja_sucursals_url, notice: 'Caja sucursal was successfully destroyed.' }
      #format.json { head :no_content }
      format.json { head :no_content}
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_caja_sucursal
      @caja_sucursal = CajaSucursal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def caja_sucursal_params
      params.require(:caja_sucursal).permit(:numero_caja, :nombre, :saldo, :sucursal_id, :perfil_id)
    end

    def set_usuarios
      @usuarios = []
      current_user.sucursal.users.each do |usuario|
        @usuarios << usuario.perfil
      end
    end
end
