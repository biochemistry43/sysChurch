class MetodoPagosController < ApplicationController
  before_action :set_metodo_pago, only: [:show, :edit, :update, :destroy]

  # GET /metodo_pagos
  # GET /metodo_pagos.json
  def index
    @metodo_pagos = MetodoPago.all
  end

  # GET /metodo_pagos/1
  # GET /metodo_pagos/1.json
  def show
  end

  # GET /metodo_pagos/new
  def new
    @metodo_pago = MetodoPago.new
  end

  # GET /metodo_pagos/1/edit
  def edit
  end

  # POST /metodo_pagos
  # POST /metodo_pagos.json
  def create
    @metodo_pago = MetodoPago.new(metodo_pago_params)

    respond_to do |format|
      if @metodo_pago.valid?
        if @metodo_pago.save
          #current_user.negocio.metodo_pago << @metodo_pago
          #format.html { redirect_to @metodo_pago, notice: 'Metodo pago was successfully created.' }
          #format.json { render :show, status: :created, location: @metodo_pago }
          format.json { head :no_content}
          format.js
        else
          format.json{render json: @metodo_pago.errors.full_messages, status: :unprocessable_entity}
          #format.html { render :new }
          #format.json { render json: @metodo_pago.errors, status: :unprocessable_entity }
        end
      else
        format.js { render :new }
        format.json { render json: @metodo_pago.errors.full_messages, status: :unprocessable_entity }
    end
    end
  end

  # PATCH/PUT /metodo_pagos/1
  # PATCH/PUT /metodo_pagos/1.json
  def update
    respond_to do |format|
      if @metodo_pago.update(metodo_pago_params)
        format.json { head :no_content}
        format.js
        #format.html { redirect_to @metodo_pago, notice: 'Metodo pago was successfully updated.' }
        #format.json { render :show, status: :ok, location: @metodo_pago }
      else
        format.json{render json: @metodo_pago.errors.full_messages, status: :unprocessable_entity}
        format.js { render :edit }
        #format.html { render :edit }
        #format.json { render json: @metodo_pago.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /metodo_pagos/1
  # DELETE /metodo_pagos/1.json
  def destroy
    @metodo_pago.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to metodo_pagos_url, notice: 'El método de pago fue eliminado.' }
      format.json { head :no_content }
      #format.html { redirect_to metodo_pagos_url, notice: 'Metodo pago was successfully destroyed.' }
      #format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_metodo_pago
      @metodo_pago = MetodoPago.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def metodo_pago_params
      params.require(:metodo_pago).permit(:clave, :descripcion)
    end
end
