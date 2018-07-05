class PlantillasEmailsController < ApplicationController
  before_action :set_plantillas_email, only: [:show, :edit, :update, :destroy]

  # GET /plantillas_emails
  # GET /plantillas_emails.json
  def index
    @plantillas_emails = PlantillasEmail.all
  end

  # GET /plantillas_emails/1
  # GET /plantillas_emails/1.json
  def show
  end

  # GET /plantillas_emails/new
  def new
    @plantillas_email = PlantillasEmail.new
  end

  # GET /plantillas_emails/1/edit
  def edit
  end

  # POST /plantillas_emails
  # POST /plantillas_emails.json
  def create
    @plantillas_email = PlantillasEmail.new(plantillas_email_params)

    respond_to do |format|
      if @plantillas_email.save
        format.html { redirect_to @plantillas_email, notice: 'Plantillas email was successfully created.' }
        format.json { render :show, status: :created, location: @plantillas_email }
      else
        format.html { render :new }
        format.json { render json: @plantillas_email.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plantillas_emails/1
  # PATCH/PUT /plantillas_emails/1.json
  def update
    respond_to do |format|
      if @plantillas_email.update(plantillas_email_params)
        format.html { redirect_to @plantillas_email, notice: 'Plantillas email was successfully updated.' }
        format.json { render :show, status: :ok, location: @plantillas_email }
      else
        format.html { render :edit }
        format.json { render json: @plantillas_email.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plantillas_emails/1
  # DELETE /plantillas_emails/1.json
  def destroy
    @plantillas_email.destroy
    respond_to do |format|
      format.html { redirect_to plantillas_emails_url, notice: 'Plantillas email was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plantillas_email
      @plantillas_email = PlantillasEmail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plantillas_email_params
      params.require(:plantillas_email).permit(:asunto_email, :msg_email, :comprobante, :negocio_id)
    end
end
