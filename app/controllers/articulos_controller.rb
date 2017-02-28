class ArticulosController < ApplicationController
  #before_filter :authenticate_user!

  before_action :set_articulo, only: [:show, :edit, :update, :destroy]


  # GET /articulos
  # GET /articulos.json
  def index
    if current_user.perfil
      @articulos = Articulo.all
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
    articulo = Articulo.where('clave = ?', @criteria)
    render :json => articulo
  end
    
  def showByCriteria
    @criteria = params[:criteria]
    articulos = Articulo.where('nombre LIKE ? OR clave LIKE ?', @criteria + '%', @criteria  + '%')
    render :json => articulos
  end

  # GET /articulos/new
  def new
    @categories = CatArticulo.all
    @articulo = Articulo.new
  end

  # GET /articulos/1/edit
  def edit
    @categories = CatArticulo.all
  end

  # POST /articulos
  # POST /articulos.json
  def create
    @categories = CatArticulo.all
    @articulo = Articulo.new(articulo_params)
    
    respond_to do |format|
      if @articulo.save
        format.html { redirect_to @articulo, notice: 'Articulo was successfully created.' }
        format.json { render :show, status: :created, location: @articulo }
      else
        format.html { render :new }
        format.json { render json: @articulo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articulos/1
  # PATCH/PUT /articulos/1.json
  def update
    @categories = CatArticulo.all
    respond_to do |format|
      if @articulo.update(articulo_params)
        format.html { redirect_to @articulo, notice: 'Articulo was successfully updated.' }
        format.json { render :show, status: :ok, location: @articulo }
      else
        format.html { render :edit }
        format.json { render json: @articulo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articulos/1
  # DELETE /articulos/1.json
  def destroy
    @articulo.destroy
    respond_to do |format|
      format.html { redirect_to articulos_url, notice: 'Articulo was successfully destroyed.' }
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
      params.require(:articulo).permit(:clave, :nombre, :descripcion, :stock, :cat_articulo_id, :existencia, :precioCompra, :precioVenta, :fotoProducto)
    end
end
