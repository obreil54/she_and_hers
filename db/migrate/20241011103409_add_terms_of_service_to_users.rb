class AddTermsOfServiceToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :terms_of_service, :boolean
  end
end
