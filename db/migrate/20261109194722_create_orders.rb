class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.uuid :uid
      t.datetime :completed_at
      t.string :discount_code
      t.string :promotion_codes, array: true, default: [], null: false

      t.timestamps

      t.index :uid, unique: true
    end
  end
end
