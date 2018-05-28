class PresentacionProductosController < ApplicationController
  before_action :set_presentacion_producto, only: [:show, :edit, :update, :destroy]

  # GET /presentacion_productos
  # GET /presentacion_productos.json
  def index
    @presentacion_productos = current_user.negocio.presentacion_productos
  end

  # GET /presentacion_productos/1
  # GET /presentacion_productos/1.json
  def show
  end

  # GET /presentacion_productos/new
  def new
    @presentacion_producto = PresentacionProducto.new
  end

  # GET /presentacion_productos/1/edit
  def edit
  end

  # POST /presentacion_productos
  # POST /presentacion_productos.json
  def create
    @presentacion_producto = PresentacionProducto.new(presentacion_producto_params)

    respond_to do |format|
      if @presentacion_producto.valid?
        current_user.negocio.presentacion_productos << @presentacion_producto
        if @presentacion_producto.save
          #format.html { redirect_to @presentacion_producto, notice: 'Presentacion producto was successfully created.' }
          #format.json { render :show, status: :created, location: @presentacion_producto }
          format.json { head :no_content}
          format.js
        else
          #format.html { render :new }
          #format.json { render json: @presentacion_producto.errors, status: :unprocessable_entity }
          format.json {render json: @presentacion_producto.errors.full_messages, status: :unprocessable_entity}
          format.js {render :new}
        end
      else
        format.js { render :new }
        format.json { render json: @presentacion_producto.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /presentacion_productos/1
  # PATCH/PUT /presentacion_productos/1.json
  def update
    respond_to do |format|
      if @presentacion_producto.update(presentacion_producto_params)
        format.json { head :no_content}
        format.js
        #format.html { redirect_to @presentacion_producto, notice: 'Presentacion producto was successfully updated.' }
        #format.json { render :show, status: :ok, location: @presentacion_producto }
      else
        format.json {render json: @articulo.errors.full_messages, status: :unprocessable_entity}
        format.js {render :edit}
        #format.html { render :edit }
        #format.json { render json: @presentacion_producto.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /presentacion_productos/1
  # DELETE /presentacion_productos/1.json
  def destroy
    @presentacion_producto.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to presentacion_productos_url, notice: 'Presentacion producto was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_presentacion_producto
      @presentacion_producto = PresentacionProducto.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def presentacion_producto_params
      params.require(:presentacion_producto).permit(:nombre)
    end
end
