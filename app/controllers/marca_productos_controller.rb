class MarcaProductosController < ApplicationController
  before_action :set_marca_producto, only: [:show, :edit, :update, :destroy]

  # GET /marca_productos
  # GET /marca_productos.json
  def index
    @marca_productos = MarcaProducto.all
  end

  # GET /marca_productos/1
  # GET /marca_productos/1.json
  def show
  end

  # GET /marca_productos/new
  def new
    @marca_producto = MarcaProducto.new
  end

  # GET /marca_productos/1/edit
  def edit
  end

  # POST /marca_productos
  # POST /marca_productos.json
  def create
    @marca_producto = MarcaProducto.new(marca_producto_params)

    respond_to do |format|
      if @marca_producto.save
        format.html { redirect_to @marca_producto, notice: 'Marca producto was successfully created.' }
        format.json { render :show, status: :created, location: @marca_producto }
      else
        format.html { render :new }
        format.json { render json: @marca_producto.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /marca_productos/1
  # PATCH/PUT /marca_productos/1.json
  def update
    respond_to do |format|
      if @marca_producto.update(marca_producto_params)
        format.html { redirect_to @marca_producto, notice: 'Marca producto was successfully updated.' }
        format.json { render :show, status: :ok, location: @marca_producto }
      else
        format.html { render :edit }
        format.json { render json: @marca_producto.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /marca_productos/1
  # DELETE /marca_productos/1.json
  def destroy
    @marca_producto.destroy
    respond_to do |format|
      format.html { redirect_to marca_productos_url, notice: 'Marca producto was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_marca_producto
      @marca_producto = MarcaProducto.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def marca_producto_params
      params.require(:marca_producto).permit(:nombre)
    end
end
