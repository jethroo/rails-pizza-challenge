class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.belongs_to :order
      t.string :name
      t.integer :size, null: false
      t.string :extra_ingredients, array: true, default: [], null: false
      t.string :omitted_ingredients, array: true, default: [], null: false

      t.timestamps
    end
  end
end
