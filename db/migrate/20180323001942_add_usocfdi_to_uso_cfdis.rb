class AddUsocfdiToUsoCfdis < ActiveRecord::Migration
  def change
    add_reference :uso_cfdis, :uso_cfdi, index: true, foreign_key: true
  end
end
