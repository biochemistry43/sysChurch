class UsuariosController < ApplicationController
  #load_and_authorize_resource
  before_action :set_usuario, only: [:edit, :update, :destroy]

  # GET /usuarios
  # GET /usuarios.json
  def index
    @usuarios = Usuario.all
  end

  # GET /usuarios/1
  # GET /usuarios/1.json
  def show
  end

  # GET /usuarios/new
  def new
    @usuario = Usuario.new
  end

  # GET /usuarios/1/edit
  def edit
  end

  # POST /usuarios
  # POST /usuarios.json
  def create
    @usuario = Usuario.new(usuario_params)

    respond_to do |format|
      if @usuario.save
        #format.html { redirect_to @usuario, notice: 'Usuario was successfully created.' }
        #format.json { render :show, status: :created, location: @usuario }
        format.json { head :no_content}
        format.js
      else
        #format.html { render :new }
        #format.json { render json: @usuario.errors, status: :unprocessable_entity }
        format.json{render json: @usuario.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /usuarios/1
  # PATCH/PUT /usuarios/1.json
  def update
    respond_to do |format|
      if @usuario.update(usuario_params)
        format.json { head :no_content}
        format.js
        #format.html { redirect_to @usuario, notice: 'Usuario was successfully updated.' }
        #format.json { render :show, status: :ok, location: @usuario }
      else
        #format.html { render :edit }
        #format.json { render json: @usuario.errors, status: :unprocessable_entity }
        format.json{render json: @usuario.errors.full_messages, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /usuarios/1
  # DELETE /usuarios/1.json
  def destroy
    @usuario.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to usuarios_url, notice: 'Usuario was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_usuario
      @usuario = Usuario.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def usuario_params
      params.require(:usuario).permit(:nombreUsuario, :contrasena, :persona_id, :tipoUsuario_id)
    end
end
