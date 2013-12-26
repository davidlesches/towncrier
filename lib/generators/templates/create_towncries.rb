class CreateTowncries < ActiveRecord::Migration
  def change
    create_table :towncries do |t|
      t.string :name
      t.integer :target_id
      t.string :target_type
      t.integer :crier_id
      t.string :crier_type
      t.string :action
      t.string :payload

      t.timestamps
    end
  end
end
