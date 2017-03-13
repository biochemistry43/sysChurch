class ClientesController < ApplicationController
  before_action :set_cliente, only: [:show, :edit, :update, :destroy]

  def index
    @clientes = current_user.negocio.clientes
  end

  def edit
  end

  def show
  end

  def new
    @cliente = Cliente.new
  end

  def destroy
    @cliente.destroy
    respond_to do |format|
      format.html { redirect_to clientes_path, notice: 'El cliente ha sido eliminado.' }
      format.json { head :no_content }
    end
  end

  def update
    respond_to do |format|
      if @cliente.update(cliente_params)
        format.html { redirect_to @cliente, notice: 'Las datos del cliente han sido actualizados' }
        format.json { render :show, status: :ok, location: @cliente }
      else
        format.html { render :edit }
        format.json { render json: @cliente.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @cliente = Cliente.new(cliente_params)

    respond_to do |format|
      if @cliente.save
        current_user.negocio.clientes << @cliente
        format.html { redirect_to @cliente, notice: 'Creación exitosa del nuevo cliente' }
        format.json { render :show, status: :created, location: @cliente }
      else
        format.html { render :new }
        format.json { render json: @cliente.errors, status: :unprocessable_entity }
      end
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cliente
      @cliente = Cliente.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cliente_params
      params.require(:cliente).permit(:nombre, :direccionCalle, :direccionNumeroExt, :direccionNumeroInt, :direccionColonia, :direccionMunicipio, :direccionDelegacion, :direccionEstado, :direccionCp, :foto, :telefono1, :telefono2, :email)
    end

end
