class PerfilsController < ApplicationController
  before_action :set_perfil, only: [:show, :edit, :update]

  def new
  	@perfil = Perfil.new
  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @perfil.update(perfil_params)
        format.html { redirect_to @perfil, notice: 'Perfil was successfully updated.' }
        format.json { render :edit, status: :ok, location: @perfil }
      else
        format.html { render :edit }
        format.json { render json: @perfil.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @perfil = Perfil.new(perfil_params)

    current_user.perfil = @perfil
    
    respond_to do |format|
      if @perfil.save
        format.html { redirect_to @perfil, notice: 'Perfil was successfully created.' }
        format.json { render :edit, status: :created, location: @perfil }
      else
        format.html { render :new }
        format.json { render json: @perfil.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_perfil
      @perfil = Perfil.find(params[:id])
    end

    def perfil_params
      params.require(:perfil).permit(:nombre, :ape_materno, :ape_paterno, :dir_calle, :dir_numero_ext, :dir_numero_int, :dir_colonia, :dir_municipio, :dir_delegacion, :dir_estado, :dir_cp, :foto)
    end

end
