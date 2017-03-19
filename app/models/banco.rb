class Banco < ActiveRecord::Base
	belongs_to :negocio

	validates :tipoCuenta, :nombreCuenta, :numeroCuenta, :saldoInicial, :fecha, :presence => {message: "No puede dejarse vacío este campo"}
	validates :nombreCuenta, uniqueness: { message: "El nombre de cuenta ya existe" }
	validates :numeroCuenta, uniqueness: { message: "El número de cuenta ya existe" }
	validates :saldoInicial, :numericality => { message: "El saldo debe ser un valor numérico" }
	validates :numeroCuenta, :numericality => { message: "Sólo números enteros", only_integer: true}

end
