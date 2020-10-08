class CreateCatches < ActiveRecord::Migration[5.2]
  def change
    create_table :catches do |t|
    	t.integer :shop_id
    	t.string :name
    	t.float :back
    	t.integer :back_date
    	t.integer :agreement
    	t.integer :agreement_date
    	t.timestamps
    end
  end
end
