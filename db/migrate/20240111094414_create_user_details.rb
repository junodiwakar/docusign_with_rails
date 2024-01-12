class CreateUserDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :user_details do |t|
      t.string :full_name
      t.string :email
      t.string :phone_no
      t.string :address

      t.timestamps
    end
  end
end
