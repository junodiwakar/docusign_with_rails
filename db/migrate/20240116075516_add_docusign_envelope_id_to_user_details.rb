class AddDocusignEnvelopeIdToUserDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :user_details, :docusign_envelope_id, :string
  end
end
