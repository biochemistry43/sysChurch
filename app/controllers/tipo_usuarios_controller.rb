class TipoUsuariosController < ApplicationController
<<<<<<< HEAD
  #load_and_authorize_resource
  before_action :set_tipo_usuario, only: [:show, :edit, :update, :destroy]
=======
  before_action :set_tipo_usuario, only: [:edit, :update, :destroy]
>>>>>>> e9ebd3c8df579ef75da7f2d91e6a22b4913eeb24

  # GET /tipo_usuarios
  # GET /tipo_usuarios.json
  def index
    @tipo_usuarios = TipoUsuario.all
  end

  # GET /tipo_usuarios/1
  # GET /tipo_usuarios/1.json
  def show
  end

  # GET /tipo_usuarios/new
  def new
    @tipo_usuario = TipoUsuario.new
  end

  # GET /tipo_usuarios/1/edit
  def edit
  end

  # POST /tipo_usuarios
  # POST /tipo_usuarios.json
  def create
    @tipo_usuario = TipoUsuario.new(tipo_usuario_params)

    respond_to do |format|
      if @tipo_usuario.save
        #format.html { redirect_to @tipo_usuario, notice: 'Tipo usuario was successfully created.' }
        #format.json { render :show, status: :created, location: @tipo_usuario }
        format.json { head :no_content}
        format.js
      else
        #format.html { render :new }
        #format.json { render json: @tipo_usuario.errors, status: :unprocessable_entity }
        format.json{render json: @tipo_usuario.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /tipo_usuarios/1
  # PATCH/PUT /tipo_usuarios/1.json
  def update
    respond_to do |format|
      if @tipo_usuario.update(tipo_usuario_params)
        format.json { head :no_content}
        format.js
        #format.html { redirect_to @tipo_usuario, notice: 'Tipo usuario was successfully updated.' }
        #format.json { render :show, status: :ok, location: @tipo_usuario }
      else
        #format.html { render :edit }
        #format.json { render json: @tipo_usuario.errors, status: :unprocessable_entity }
        format.json{render json: @tipo_usuario.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /tipo_usuarios/1
  # DELETE /tipo_usuarios/1.json
  def destroy
    @tipo_usuario.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to tipo_usuarios_url, notice: 'Tipo usuario was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tipo_usuario
      @tipo_usuario = TipoUsuario.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tipo_usuario_params
      params.require(:tipo_usuario).permit(:nombreTipo, :descripcionTipo, :isVentas, :isInventarios, :isPerdidas, :isPersonas, :isGastos)
    end
end
