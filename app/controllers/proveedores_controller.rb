class ProveedoresController < ApplicationController
  before_action :set_proveedor, only: [:edit, :update, :destroy]

  # GET /proveedores
  # GET /proveedores.json
  def index
    @proveedores = current_user.sucursal.proveedores
  end

  # GET /proveedores/1
  # GET /proveedores/1.json
  def show
  end

  # GET /proveedores/new
  def new
    @proveedor = Proveedor.new
  end

  # GET /proveedores/1/edit
  def edit
  end

  # POST /proveedores
  # POST /proveedores.json
  def create
    @proveedor = Proveedor.new(proveedor_params)

    respond_to do |format|
      if @proveedor.valid?
        if @proveedor.save
          current_user.sucursal.proveedores << @proveedor
          current_user.negocio.proveedores<< @proveedor
          #format.html { redirect_to @proveedor, notice: 'Proveedor was successfully created.' }
          #format.json { render :show, status: :created, location: @proveedor }
          format.json { head :no_content}
          format.js
        else
          #format.html { render :new }
          #format.json { render json: @proveedor.errors, status: :unprocessable_entity }
          format.js { render :new }
          format.json{render json: @proveedor.errors.full_messages, status: :unprocessable_entity}
        end
      else
        format.js { render :new }
        format.json{render json: @proveedor.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /proveedores/1
  # PATCH/PUT /proveedores/1.json
  def update
    respond_to do |format|
      if @proveedor.update(proveedor_params)
        format.json { head :no_content}
        format.js
        #format.html { redirect_to @proveedor, notice: 'Proveedor was successfully updated.' }
        #format.json { render :show, status: :ok, location: @proveedor }
      else
        #format.html { render :edit }
        #format.json { render json: @proveedor.errors, status: :unprocessable_entity }
        format.js { render :edit }
        format.json{render json: @proveedor.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /proveedores/1
  # DELETE /proveedores/1.json
  def destroy
    @proveedor.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to proveedores_url, notice: 'Proveedor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_proveedor
      @proveedor = Proveedor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def proveedor_params
      params.require(:proveedor).permit(:nombre, :telefono, :email, :nombreContacto, :telefonoContacto, :emailContacto, :celularContacto)
    end
end
