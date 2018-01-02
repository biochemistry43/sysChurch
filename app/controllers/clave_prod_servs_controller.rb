class ClaveProdServsController < ApplicationController
  before_action :set_clave_prod_serv, only: [:show, :edit, :update, :destroy]

  # GET /clave_prod_servs
  # GET /clave_prod_servs.json
  def index
    @clave_prod_servs = ClaveProdServ.all
  end

  # GET /clave_prod_servs/1
  # GET /clave_prod_servs/1.json
  def show
  end

  # GET /clave_prod_servs/new
  def new
    @clave_prod_serv = ClaveProdServ.new
  end

  # GET /clave_prod_servs/1/edit
  def edit
  end

  # POST /clave_prod_servs
  # POST /clave_prod_servs.json
  def create
    @clave_prod_serv = ClaveProdServ.new(clave_prod_serv_params)

    respond_to do |format|
      if @clave_prod_serv.valid?
        if @clave_prod_serv.save
          #format.html { redirect_to @clave_prod_serv, notice: 'Clave prod serv was successfully created.' }
          #format.json { render :show, status: :created, location: @clave_prod_serv }
          format.json { head :no_content}
          format.js
        else
          #format.html { render :new }
          #format.json { render json: @clave_prod_serv.errors, status: :unprocessable_entity }
          format.json{render json: @clave_prod_serv.errors.full_messages, status: :unprocessable_entity}
        end
      else
        format.js { render :new }
        format.json { render json: @clave_prod_serv.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clave_prod_servs/1
  # PATCH/PUT /clave_prod_servs/1.json
  def update
    respond_to do |format|
      if @clave_prod_serv.update(clave_prod_serv_params)
        #format.html { redirect_to @clave_prod_serv, notice: 'Clave prod serv was successfully updated.' }
        #format.json { render :show, status: :ok, location: @clave_prod_serv }
        format.json { head :no_content}
        format.js
      else
        format.json{render json: @clave_prod_serv.errors.full_messages, status: :unprocessable_entity}
        format.js { render :edit }
        #format.html { render :edit }
        #format.json { render json: @clave_prod_serv.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clave_prod_servs/1
  # DELETE /clave_prod_servs/1.json
  def destroy
    @clave_prod_serv.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to clave_prod_servs_url, notice: 'La categoria fue eliminada' }
      format.json { head :no_content }
      #format.html { redirect_to clave_prod_servs_url, notice: 'Clave prod serv was successfully destroyed.' }
      #format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_clave_prod_serv
      @clave_prod_serv = ClaveProdServ.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def clave_prod_serv_params
      params.require(:clave_prod_serv).permit(:clave, :nombre)
    end
end
