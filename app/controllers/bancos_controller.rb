class BancosController < ApplicationController
<<<<<<< HEAD
  before_action :set_banco, only: [:show, :edit, :update, :destroy]
=======
  before_action :set_banco, only: [:edit, :update, :destroy]

>>>>>>> e9ebd3c8df579ef75da7f2d91e6a22b4913eeb24
  # GET /bancos
  # GET /bancos.json
  def index
    @bancos = Banco.all
  end

  # GET /bancos/1
  # GET /bancos/1.json
  def show
  end

  # GET /bancos/new
  def new
    @banco = Banco.new
  end

  # GET /bancos/1/edit
  def edit
  end

  # POST /bancos
  # POST /bancos.json
  def create
    @banco = Banco.new(banco_params)

    respond_to do |format|
      if @banco.save
        current_user.negocio.bancos << @banco
        #format.html { redirect_to @banco, notice: 'Banco was successfully created.' }
        #format.json { render :show, status: :created, location: @banco }
        format.json { head :no_content}
        format.js
      else
        #format.html { render :new }
        #format.json { render json: @banco.errors, status: :unprocessable_entity }
        format.json{render json: @banco.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /bancos/1
  # PATCH/PUT /bancos/1.json
  def update
    respond_to do |format|
      if @banco.update(banco_params)
        format.json { head :no_content}
        format.js
        #format.html { redirect_to @banco, notice: 'Banco was successfully updated.' }
        #format.json { render :show, status: :ok, location: @banco }
      else
        #format.html { render :edit }
        #format.json { render json: @banco.errors, status: :unprocessable_entity }
        format.json{render json: @banco.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /bancos/1
  # DELETE /bancos/1.json
  def destroy
    @banco.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to bancos_url, notice: 'Banco was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_banco
      @banco = Banco.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def banco_params
      params.require(:banco).permit(:tipoCuenta, :nombreCuenta, :numeroCuenta, :saldoInicial, :fecha, :descripcion)
    end
end
