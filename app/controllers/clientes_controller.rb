class ClientesController < ApplicationController
  before_action :set_cliente, only: [:edit, :update, :destroy]

  def index
    @clientes = current_user.negocio.clientes.order(:nombre)
  end

  def edit
  end

  def show
  end

  def new
    @cliente = Cliente.new
  end

  def destroy
    @cliente.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to clientes_path, notice: 'El cliente ha sido eliminado.' }
      format.json { head :no_content }
    end
  end

  def update

    nombreFiscal_f = params[:nombreFiscal_f]
    rfc_f = params[:rfc_f]
    calle_f = params[:calle_f ]
    numExterior_f = params[:numExterior_f]
    numInterior_f = params[:numInterior_f]
    colonia_f = params[:colonia_f]
    localidad_f = params[:localidad_f]

    municipio_f = params[:municipio_f]
    estado_f = params[:estado_f]
    codigo_postal_f = params[:codigo_postal_f]
    pais_f = params[:pais_f]
    referencia_f = params[:referencia_f]


    respond_to do |format|
      if @cliente.update(cliente_params)
        if @cliente.datos_fiscales_cliente.present?
          @cliente.datos_fiscales_cliente.update(nombreFiscal:nombreFiscal_f, rfc:rfc_f, calle:calle_f, numExterior: numExterior_f, numInterior: numInterior_f, colonia: colonia_f, localidad:localidad_f, municipio: municipio_f, estado:estado_f, codigo_postal: codigo_postal_f, referencia: referencia_f, pais: pais_f)
        elsif nombreFiscal_f.length > 0 && rfc_f.length > 0
          @datosFiscalesCliente=DatosFiscalesCliente.new(nombreFiscal:nombreFiscal_f, rfc:rfc_f, calle:calle_f, numExterior: numExterior_f, numInterior: numInterior_f, colonia: colonia_f, localidad:localidad_f, municipio: municipio_f, estado:estado_f, codigo_postal: codigo_postal_f, referencia: referencia_f, pais: pais_f)
          @cliente.datos_fiscales_cliente = @datosFiscalesCliente if @datosFiscalesCliente.save && nombreFiscal_f.length > 0 && rfc_f.length > 0
        end

        format.json { head :no_content }
        format.js
        #format.html { redirect_to @cliente, notice: 'Las datos del cliente han sido actualizados' }
        #format.json { render :show, status: :ok, location: @cliente }
      else
        #format.html { render :edit }
        #format.json { render json: @cliente.errors, status: :unprocessable_entity }
        format.json{render json: @cliente.errors.full_messages, status: :unprocessable_entity}
        format.js { render :edit }
      end
    end
  end

  def create
    @cliente = Cliente.new(cliente_params)

    nombreFiscal_f = params[:nombreFiscal_f]
    rfc_f = params[:rfc_f]
    calle_f = params[:calle_f ]
    numExterior_f = params[:numExterior_f]
    numInterior_f = params[:numInterior_f]
    colonia_f = params[:colonia_f]
    localidad_f = params[:localidad_f]

    municipio_f = params[:municipio_f]
    estado_f = params[:estado_f]
    codigo_postal_f = params[:codigo_postal_f]
    pais_f = params[:pais_f]
    referencia_f = params[:referencia_f]

    @datosFiscalesCliente=DatosFiscalesCliente.new(nombreFiscal:nombreFiscal_f, rfc:rfc_f, calle:calle_f, numExterior: numExterior_f, numInterior: numInterior_f, colonia: colonia_f, localidad:localidad_f, municipio: municipio_f, estado:estado_f, codigo_postal: codigo_postal_f, pais:pais_f, referencia:referencia_f)

    respond_to do |format|
      if @cliente.valid?
        if @cliente.save
          current_user.negocio.clientes << @cliente
          if nombreFiscal_f.length > 0 && rfc_f.length > 0

            @cliente.datos_fiscales_cliente = @datosFiscalesCliente if @datosFiscalesCliente.save
          end
          #format.html { redirect_to @cliente, notice: 'Creación exitosa del nuevo cliente' }
          #format.json { render :show, status: :created, location: @cliente }
          format.json { head :no_content}
          format.js
        else
          #format.html { render :new }
          #format.json { render json: @cliente.errors, status: :unprocessable_entity }
          format.json{render json: @cliente.errors.full_messages, status: :unprocessable_entity}
        end
      else
        format.js { render :new }
        format.json { render json: @cliente.errors.full_messages, status: :unprocessable_entity }
      end

    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cliente
      @cliente = Cliente.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cliente_params
      params.require(:cliente).permit(:nombre, :direccionCalle, :direccionNumeroExt, :direccionNumeroInt, :direccionColonia, :direccionMunicipio, :direccionDelegacion, :direccionEstado, :direccionCp, :telefono1, :telefono2, :email, :ape_pat, :ape_mat, :fecha_nac)
    end

end
