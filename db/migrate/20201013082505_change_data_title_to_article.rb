class ChangeDataTitleToArticle < ActiveRecord::Migration[5.2]
  def change
  	change_column :tables, :set_count, :integer
  end
end
