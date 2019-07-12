class AddReviewToLiteral < ActiveRecord::Migration[5.2]
  def change
    add_column :literals, :review, :boolean
  end
end
