class AddDegreeToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :degree, :boolean, default: false
  end
end
