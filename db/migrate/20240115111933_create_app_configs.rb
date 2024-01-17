class CreateAppConfigs < ActiveRecord::Migration[7.1]
  def change
    create_table :app_configs do |t|
      t.string :key
      t.text :value

      t.timestamps
    end
  end
end
