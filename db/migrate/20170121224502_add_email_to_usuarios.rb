class AddEmailToUsuarios < ActiveRecord::Migration
  def change
    add_column :usuarios, :email, :string
  end
end
