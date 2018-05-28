class SucursalsController < ApplicationController
  before_action :set_sucursal, only: [:edit, :update, :destroy]

  # GET /sucursals
  # GET /sucursals.json
  def index
    @sucursals = current_user.negocio.sucursals
  end

  # GET /sucursals/1
  # GET /sucursals/1.json
  def show
  end

  # GET /sucursals/new
  def new
    @sucursal = Sucursal.new
  end

  # GET /sucursals/1/edit
  def edit
  end

  # POST /sucursals
  # POST /sucursals.json
  def create
    @sucursal = Sucursal.new(sucursal_params)  
    respond_to do |format|
      if @sucursal.valid?
        current_user.negocio.sucursals << @sucursal
        if @sucursal.save
          format.js
          format.html { redirect_to @sucursal, notice: 'La sucursal fue creada.' }
          format.json { render :show, status: :created, location: @sucursal }
        else
          format.js { render :new }
          format.html { render :new }
          format.json { render json: @sucursal.errors, status: :unprocessable_entity }
        end
      else
        format.js { render :new }
        format.json {render json: @sucursal.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /sucursals/1
  # PATCH/PUT /sucursals/1.json
  def update
    respond_to do |format|
      if @sucursal.update(sucursal_params)
        format.json { head :no_content}
        format.js
        #format.html { redirect_to @sucursal, notice: 'Sucursal was successfully updated.' }
        #format.json { render :show, status: :ok, location: @sucursal }
      else
        #format.html { render :edit }
        #format.json { render json: @sucursal.errors, status: :unprocessable_entity }
        format.json {render json: @articulo.errors.full_messages, status: :unprocessable_entity}
        format.js {render :edit}
      end
    end
  end

  # DELETE /sucursals/1
  # DELETE /sucursals/1.json
  def destroy
    @sucursal.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to sucursals_url, notice: 'La Sucursal fue eliminada.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sucursal
      @sucursal = Sucursal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sucursal_params
      params.require(:sucursal).permit(:nombre, :representante, :calle, :numExterior, :numInterior, :colonia, :codigo_postal, :municipio, :delegacion, :estado, :email)
    end
end
