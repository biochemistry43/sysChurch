class ArticulosController < ApplicationController
  #before_filter :authenticate_user!
  load_and_authorize_resource
  before_action :set_articulo, only: [:edit, :update, :destroy]
  before_action :set_art_categories, only: [:index, :consulta_avanzada, :solo_sucursal, :baja_existencia]
  before_action :set_marcas, only: [:index, :consulta_avanzada, :solo_sucursal, :baja_existencia]
  before_action :set_sucursales, only: [:index, :consulta_avanzada, :solo_sucursal, :baja_existencia]


  # GET /articulos
  # GET /articulos.json
  def index
    if current_user.perfil
      if can? :create, Negocio
        @articulos = current_user.negocio.articulos
      else
        @solo_sucursal = true
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

    if Rails.env.development?
      articulos = Articulo.where('(nombre LIKE ? OR clave LIKE ?) AND (sucursal_id = ?) AND (negocio_id = ?)', @criteria + '%', @criteria  + '%', current_user.sucursal.id, current_user.negocio.id)
    elsif Rails.env.production?
      articulos = Articulo.where('(nombre ILIKE ? OR clave ILIKE ?) AND (sucursal_id = ?) AND (negocio_id = ?)', @criteria + '%', @criteria  + '%', current_user.sucursal.id, current_user.negocio.id)
    end

    #articulos = Articulo.where('(nombre LIKE ? OR clave LIKE ?) AND (sucursal_id = ?)', @criteria + '%', @criteria  + '%', current_user.sucursal.id)    
    render :json => articulos
  end

  def showByCriteriaForPos
    @criteria = params[:criteria]

    if Rails.env.development?
      articulos = Articulo.where('(nombre LIKE ? OR clave LIKE ?) AND (sucursal_id = ?) AND (tipo = ?) AND (negocio_id = ?)', @criteria + '%', @criteria  + '%', current_user.sucursal.id, 'comercializable', current_user.negocio.id)
    elsif Rails.env.production?
      articulos = Articulo.where('(nombre ILIKE ? OR clave ILIKE ?) AND (sucursal_id = ?) AND (tipo = ?) AND (negocio_id = ?)', @criteria + '%', @criteria  + '%', current_user.sucursal.id, 'comercializable', current_user.negocio.id)
    end

    #articulos = Articulo.where('(nombre LIKE ? OR clave LIKE ?) AND (sucursal_id = ?)', @criteria + '%', @criteria  + '%', current_user.sucursal.id)    
    render :json => articulos
  end

  def solo_sucursal
    @solo_sucursal = true
    @articulos = current_user.sucursal.articulos
  end

  #llena una array con los articulos que tengan una existencia menor o igual
  #a la de su stock
  def baja_existencia
    @articulos = []

    current_user.sucursal.articulos.each do |articulo|
      if articulo.existencia <= articulo.stock
        @articulos << articulo
      end
    end
  end

  def consulta_avanzada
    @consulta = true
    @avanzada = true
    if request.post?
      cat = params[:cat_elegida]
      mar = params[:marca_elegida]
      suc = params[:suc_elegida]
      @categoria = nil
      @marca = nil
      @sucursal = nil
      
      unless cat.empty?
        @categoria = CatArticulo.find(cat)
      end
      
      unless mar.empty?
        @marca = MarcaProducto.find(mar)
      end

      unless suc.empty?
        @sucursal = Sucursal.find(suc)
      end
      
      if @categoria
        unless @sucursal && @marca
          if can? :create, Negocio
            @articulos = current_user.negocio.articulos.where(:cat_articulo=>@categoria)
          else
            @articulos = current_user.negocio.articulos.where(:cat_articulo=>@categoria)
          end
        end
      end

      if @marca
        unless @categoria && @sucursal
          if can? :create, Negocio
            @articulos = current_user.negocio.articulos.where(:marca_producto=>@marca)
          else
            @articulos = current_user.negocio.articulos.where(:marca_producto=>@marca)
          end
        end
      end

      if @sucursal
        unless @marca && @categoria
          if can? :create, Negocio
            @articulos = current_user.negocio.articulos.where(:sucursal=>@sucursal)
          else
            @articulos = current_user.sucursal.articulos.where(:sucursal=>@sucursal)
          end
        end
      end

      if @sucursal && @marca
        unless @categoria
          if can? :create, Negocio
            @articulos = current_user.negocio.articulos.where(:sucursal=>@sucursal, :marca_producto=>@marca)
          else
            @articulos = current_user.sucursal.articulos.where(:sucursal=>@sucursal, :marca_producto=>@marca)
          end
        end
      end

      if @sucursal && @categoria
        unless @marca
          if can? :create, Negocio
            @articulos = current_user.negocio.articulos.where(:sucursal=>@sucursal, :cat_articulo=>@categoria)
          else
            @articulos = current_user.sucursal.articulos.where(:sucursal=>@sucursal, :cat_articulo=>@categoria)
          end
        end
      end

      if @marca && @categoria
        unless @sucursal
          if can? :create, Negocio
            @articulos = current_user.negocio.articulos.where(:marca_producto=>@marca, :cat_articulo=>@categoria)
          else
            @articulos = current_user.sucursal.articulos.where(:marca_producto=>@marca, :cat_articulo=>@categoria)
          end
        end
      end

      if @marca && @categoria && @sucursal
        if can? :create, Negocio
            @articulos = current_user.negocio.articulos.where(:marca_producto=>@marca, :cat_articulo=>@categoria, :sucursal=>@sucursal)
          else
            @articulos = current_user.sucursal.articulos.where(:marca_producto=>@marca, :cat_articulo=>@categoria, :sucursal=>@sucursal)
          end
      end
    end
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

    # Un usuario administrador o un gerente de sucursal, puede asignar una existencia inicial
    # a un producto desde el momento que se crea. Esta opción estará disponible únicamente
    # al momento de crearse y no hay posibilidad de editar este dato.
    existenciaInicial = articulo_params[:existencia]

    #suc guarda la sucursal elegida por un usuario administrador.
    #Un usuario administrador tiene la facultad de elegir a que sucursal u/o almacen
    #puede asignar un producto determinado. esta opción no estará visible para todos  los
    #roles. Por ejemplo, un gerente de sucursal, sólo puede agregar productos para su propia
    #sucursal.
    suc = articulo_params[:suc_elegida]

    unless suc
      suc = ""
    end

    @articulo = Articulo.new(articulo_params)

    #Si el usuario no asignó ninguna sucursal en especial para este artículo, entonces
    #el nombre asignado de sucursal para este producto, será la misma sucursal a la que el usuario
    #pertence.
    if suc.empty?
      @articulo.suc_elegida = current_user.sucursal.nombre
    end
    
    respond_to do |format|
      if @articulo.valid?
        if @articulo.save
          #añado el articulo a la lista de articulos pertenecientes al negocio
          current_user.negocio.articulos << @articulo

          #Si el usuario no eligió una sucursal para asignar el artículo, entonces añado el artículo
          #a la sucursal a la que el usuario pertenece.
          #De lo contrario, busco la sucursal en la tabla de sucursales, en base al nombre de la 
          #sucursal elegida y ahí es donde se asigna el artículo.
          if suc.empty?
            current_user.sucursal.articulos << @articulo
            @articulo.suc_elegida = current_user.sucursal.nombre
          else
            sucElegida = Sucursal.find(suc)
            sucElegida.articulos << @articulo
          end
          
          unless existenciaInicial
            existenciaInicial = 0
          end

          #añado una primera instancia de entrada de almacén, aunque la existencia inicial sea cero.
          entradaAlmacen = EntradaAlmacen.new(:cantidad=>existenciaInicial, :fecha=>Time.now, :isEntradaInicial=>true)
          entradaAlmacen.save

          #añado esta entrada a almacén a la lista de entradas de almacén relacionadas con el
          #artículo.
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
      @categories = current_user.negocio.cat_articulos
    end

    def set_marcas
      @marcas = current_user.negocio.marca_productos
    end

    def set_sucursales
      @sucursales = current_user.negocio.sucursals
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def articulo_params
      params.require(:articulo).permit(:clave, :nombre, :descripcion, :stock, :cat_articulo_id, :existencia, :precioCompra, :precioVenta, :fotoProducto, :marca_producto_id, :presentacion_producto_id, :suc_elegida, :tipo)
    end

end
