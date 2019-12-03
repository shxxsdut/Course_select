class AddCourseDegreeToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :course_degree, :boolean, default: false
  end
end
