class ArticulosController < ApplicationController
  #before_filter :authenticate_user!
  load_and_authorize_resource
  before_action :set_articulo, only: [:edit, :update, :destroy]


  # GET /articulos
  # GET /articulos.json
  def index
    if current_user.perfil
      if can? :update, Negocio
        @articulos = current_user.negocio.articulos
      else
        @articulos = current_user.sucursal.articulos
      end
    else
      redirect_to new_perfil_path
    end
  end

  # GET /articulos/1
  # GET /articulos/1.json
  def show
  end

  #obtiene un articulo en base a su Id
  def getById
    @criteria = params[:criteria]
    articulo = Articulo.where('clave = ? AND sucursal_id = ?', @criteria, current_user.sucursal.id)
    render :json => articulo
  end
    
  def showByCriteria
    @criteria = params[:criteria]
    articulos = Articulo.where('(nombre ILIKE ? OR clave ILIKE ?) AND (sucursal_id = ?)', @criteria + '%', @criteria  + '%', current_user.sucursal.id)
    render :json => articulos
  end

  # GET /articulos/new
  def new
    @categories = current_user.negocio.cat_articulos
    @marcas = current_user.negocio.marca_productos
    @presentaciones = current_user.negocio.presentacion_productos
    @sucursales = current_user.negocio.sucursals
    @articulo = Articulo.new
  end

  # GET /articulos/1/edit
  def edit
    @categories = current_user.negocio.cat_articulos
    @marcas = current_user.negocio.marca_productos
    @sucursales = current_user.negocio.sucursals
    @presentaciones = current_user.negocio.presentacion_productos
  end

  # POST /articulos
  # POST /articulos.json
  def create
    @categories = current_user.negocio.cat_articulos
    @marcas = current_user.negocio.marca_productos
    @sucursales = current_user.negocio.sucursals
    @presentaciones = current_user.negocio.presentacion_productos
    existenciaInicial = articulo_params[:existencia]
    suc = articulo_params[:suc_elegida]

    @articulo = Articulo.new(articulo_params)
    if suc.empty?
      @articulo.suc_elegida = current_user.sucursal.nombre
    end
    
    respond_to do |format|
      if @articulo.valid?
        if @articulo.save
          current_user.negocio.articulos << @articulo
          if suc.empty?
            current_user.sucursal.articulos << @articulo
            @articulo.suc_elegida = current_user.sucursal.nombre
          else
            sucElegida = Sucursal.find_by(nombre: suc)
            sucElegida.articulos << @articulo
          end
          entradaAlmacen = EntradaAlmacen.new(:cantidad=>existenciaInicial, :fecha=>Time.now, :isEntradaInicial=>true)
          entradaAlmacen.save
          @articulo.entrada_almacens << entradaAlmacen          
          #format.html { redirect_to @articulo, notice: 'El producto fue creado existosamente' }
          #format.json { render :show, status: :created, location: @articulo }
          format.json { head :no_content}
          format.js
        else
          #format.html { render :new }
          #format.json { render json: @articulo.errors, status: :unprocessable_entity }
          format.json {render json: @articulo.errors.full_messages, status: :unprocessable_entity}
          format.js {render :new}
        end
      else
        format.js { render :new }
        format.json {render json: @articulo.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /articulos/1
  # PATCH/PUT /articulos/1.json
  def update
    @categories = current_user.negocio.cat_articulos
    @marcas = current_user.negocio.marca_productos
    @presentaciones = current_user.negocio.presentacion_productos
    @sucursales = current_user.negocio.sucursals
    respond_to do |format|
      if @articulo.update(articulo_params)
        format.json { head :no_content}
        format.js
        #format.html { redirect_to @articulo, notice: 'El producto fue actualizado' }
        #format.json { render :show, status: :ok, location: @articulo }
      else
        #format.html { render :edit }
        #format.json { render json: @articulo.errors, status: :unprocessable_entity }
        format.json {render json: @articulo.errors.full_messages, status: :unprocessable_entity}
        format.js {render :edit}
      end
    end
  end

  # DELETE /articulos/1
  # DELETE /articulos/1.json
  def destroy
    @articulo.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to articulos_url, notice: 'El producto fue eliminado definitivamente' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_articulo
      @articulo = Articulo.find(params[:id])
    end

    def set_art_categories
      @categories = CatArticulo.all
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def articulo_params
      params.require(:articulo).permit(:clave, :nombre, :descripcion, :stock, :cat_articulo_id, :existencia, :precioCompra, :precioVenta, :fotoProducto, :marca_producto_id, :presentacion_producto_id, :suc_elegida)
    end
end
