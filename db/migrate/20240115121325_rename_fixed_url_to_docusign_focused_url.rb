class RenameFixedUrlToDocusignFocusedUrl < ActiveRecord::Migration[7.1]
  def change
    rename_column :user_details, :fixed_url, :docusign_focused_url
  end
end
