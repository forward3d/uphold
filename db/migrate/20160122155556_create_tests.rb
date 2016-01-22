class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.string :config_name
      t.boolean :is_good, default: false
      t.string :log_file
      t.timestamps null: false
    end
  end
end
