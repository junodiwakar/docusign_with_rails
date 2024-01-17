class AddDocusignFocusedUrlToUserDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :user_details, :fixed_url, :text
  end
end
