class UsoCfdisController < ApplicationController
  before_action :set_uso_cfdi, only: [:show, :edit, :update, :destroy]

  # GET /uso_cfdis
  # GET /uso_cfdis.json
  def index
    @uso_cfdis = UsoCfdi.all
  end

  # GET /uso_cfdis/1
  # GET /uso_cfdis/1.json
  def show
  end

  # GET /uso_cfdis/new
  def new
    @uso_cfdi = UsoCfdi.new
  end

  # GET /uso_cfdis/1/edit
  def edit
  end

  # POST /uso_cfdis
  # POST /uso_cfdis.json
  def create
    @uso_cfdi = UsoCfdi.new(uso_cfdi_params)

    respond_to do |format|
      if @uso_cfdi.valid?
        if @uso_cfdi.save
          #format.html { redirect_to @uso_cfdi, notice: 'Uso cfdi was successfully created.' }
          #format.json { render :show, status: :created, location: @uso_cfdi }
          format.json { head :no_content}
          format.js
        else
          #format.html { render :new }
          #format.json { render json: @uso_cfdi.errors, status: :unprocessable_entity }
          format.json{render json: @uso_cfdi.errors.full_messages, status: :unprocessable_entity}
        end
      else
        format.js { render :new }
        format.json { render json: @uso_cfdi.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /uso_cfdis/1
  # PATCH/PUT /uso_cfdis/1.json
  def update
    respond_to do |format|
      if @uso_cfdi.update(uso_cfdi_params)
        #format.html { redirect_to @uso_cfdi, notice: 'Uso cfdi was successfully updated.' }
        #format.json { render :show, status: :ok, location: @uso_cfdi }
        format.json { head :no_content}
        format.js
      else
        format.json{render json: @uso_cfdi.errors.full_messages, status: :unprocessable_entity}
        format.js { render :edit }
        #format.html { render :edit }
        #format.json { render json: @uso_cfdi.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uso_cfdis/1
  # DELETE /uso_cfdis/1.json
  def destroy
    @uso_cfdi.destroy
    respond_to do |format|
      #format.html { redirect_to uso_cfdis_url, notice: 'Uso cfdi was successfully destroyed.' }
      #format.json { head :no_content }
      format.js
      format.html { redirect_to uso_cfdis_url, notice: 'El uso fue eliminado' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_uso_cfdi
      @uso_cfdi = UsoCfdi.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def uso_cfdi_params
      params.require(:uso_cfdi).permit(:clave, :descripcion)
    end
end
