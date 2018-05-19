class CreatePlaces < ActiveRecord::Migration[5.2]
  def change
    create_table :places do |t|
      t.integer :user_id
      t.string :name
      t.string :location
      t.text :content
    end
  end
end
