class EmpleadosController < ApplicationController
  def index
    @nempleados = current_user.negocio.users
    @sempleados = current_user.sucursal.users
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end
end
