class CoursesController < ApplicationController
  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :open, :close]#add open by qiao
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)  #模型可以用相应的属性初始化，它们会自动映射到对应的数据库字段
    if @course.save  #负责把模型保存到数据库
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'   #在这里如果 @course.save 失败了，就需要把表单再次显示给用户
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])  #我们使用 Course.find 来查找文章，并传入 params[:id] 以便从请求中获得 :id 参数。
                                               #我们还使用实例变量（前缀为 @）保存对文章对象的引用。这样做是因为 Rails 会把所有实例变量传递给视图。
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def open
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: true)
    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end

  def close
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: false)
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  #-------------------------for students----------------------

  def list
    #---------------
    @courses = Course.where(:open=>false).paginate(page: params[:page], per_page: 7)
    @course = @courses-current_user.courses
    tmp=[]
    @course.each do |course|
      if course.open==false
        tmp<<course
      end
    end
    @course=tmp



  end

  #----------学生选择课程-----------
  # def select
  #   @course=Course.find_by_id(params[:id])
  #   current_user.courses<<@course
  #   flash={:suceess => "成功选择课程: #{@course.name}"}
  #   redirect_to courses_path, flash: flash
  # end
  #添加选课冲突，控制选课人数
  def select
    @course=Course.find_by_id(params[:id])
    flag=0

    current_user.courses.each do |courses|
      #课程重复选择
      if courses.name == @course.name
        flag = 1
      end
      #选课时间冲突
      if courses.course_time == @course.course_time
        flag = 2
      end
      #选课人数限制
      if @course.limit_num != nil
        puts @course.limit_num;
        puts "%%%%%%%%%%";
        puts @course.student_num;
        puts "************";
        if @course.limit_num <= @course.student_num
          flag = 3
        end
      end
    end
    #未产生选课的冲突
    if flag == 0
      current_user.courses<<@course
      @course.student_num += 1
      @course.save

      flash={:suceess => "成功选择课程: #{@course.name}"}
    end
    if flag ==1
      flash = {:fail => "课程名称冲突,你已经选择该课程：#{@course.name},"}
    end
    if flag == 2
      flash = {:notice => "该课程与其他课程时间冲突：#{@course.name}"}
    end
    if flag == 3
      flash = {:alert => "该课程选课人数达到上限：#{@course.name}"}
    end
    redirect_to courses_path, flash: flash
  end


  #--------------学生退选课程------------------
  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  #-----新增------显示课表-----------------
  def coursetable
    @course=current_user.courses if student_logged_in?
  end

  #-----新增-----显示课程详细信息--------------
  def coursedetails
    @course=Course.find_by_id(params[:id])
    if current_user.nil?
    else
      @grade=Grade.where(:course_id => params[:id],:user_id=>current_user.id).first
    end
  end
#-----------显示当前学分------------
  def credit
    @courses = current_user.courses
    @degree_credit = 0
    @get_degree_credit=0
    @sum_credit=0
    @get_sum_credit=0
    @public_credit=0
    @get_public_credit=0
    @public_must_credit
    @get_public_must_credit=0

    @courses.each do |course|
      @credit = course.credit[3..5]

      if course.name == "学术道德与学术写作规范"
        @public_must_credit = @public_must_credit + course.name+"("+@credit + "学分"+")"+"\n"
      end

      if course.name == "中国特色社会主义理论与实践研究"
        @public_must_credit = @public_must_credit + course.name+"("+@credit + "学分"+")"+"\n"
      end

      if course.name == "自然辩证法概论"
        @public_must_credit = @public_must_credit + course.name+"("+@credit + "学分"+")"+"\n"
      end

      if course.name == "硕士学位英语"
        @public_must_credit = @public_must_credit + course.name+"("+@credit + "学分"+")"+"\n"
      end


      if course.course_type=="公共必修课"
        current_user.grades.each do |grade|
          if grade.grade != nil
            if grade.course.name == course.name && grade.grade >= 60
              @get_public_must_credit += @credit.to_f
            end
          end
        end
      end




      #学位课学分统计
      @current_user.grades.each do |grade|
        if grade.course.name == course.name && grade.degree == true
          @degree_credit += @credit.to_f
        end
        if grade.grade != nil
           if grade.course.name == course.name && grade.grade >= 60
             @get_degree_credit += @credit.to_f
           end
        end
      end



      if course.course_type=="公共选修课"
        @public_credit += @credit.to_f
        current_user.grades.each do |grade|
          if grade.grade != nil
            if grade.course.name == course.name && grade.grade >= 60
              @get_public_credit += @credit.to_f

            end
          end
        end
      end

      @sum_credit += @credit.to_f

    end

    current_user.grades.each do |grade|
      if grade.grade != nil && grade.grade >= 60
        @get_sum_credit += @credit.to_f
      end
    end

  end


  #----------------查询选修课--------------------------
  def searchcourse
    @Select_exam_type = params[:select_exam_type]
    @Select_course_type = params[:select_course_type]
    @Select_credit = params[:select_credit]
    @Select_course_name = params[:select_course_name]


    @courses = Course.where(:open=>false)
    @course = @courses-current_user.courses

    if( @Select_course_type =="" && @Select_exam_type=="" &&@Select_credit=="" && @Select_course_name !="")
      tmp=[]
      @course.each do |course|
        if course.name == @Select_course_name
          tmp<<course
        end
      end

      @course=tmp
    end

    if( @Select_course_type!="" && @Select_exam_type=="" &&@Select_credit=="" && @Select_course_name =="")
      tmp=[]
      @course.each do |course|
        if course.course_type == @Select_course_type
          tmp<<course
        end
      end

      @course=tmp
    end

    if(@Select_exam_type != "" && @Select_credit=="" && @Select_course_type =="" && @Select_course_name =="")
      tmp=[]
      @course.each do |course|
        if course.exam_type == @Select_exam_type
          tmp<<course
        end
      end
      @course=tmp
    end

    if(@Select_exam_type == "" && @Select_credit!="" && @Select_course_type =="" && @Select_course_name =="")
      tmp=[]
      @course.each do |course|
        if course.credit == @Select_credit
          tmp<<course
        end
      end
      @course=tmp
    end


    if(@Select_exam_type != "" && @Select_credit!="" && @Select_course_type !="" && @Select_course_name !="")
      tmp=[]
      @course.each do |course|
        if course.credit == @Select_credit && course.course_type ==@Select_course_type && course.exam_type == @Select_exam_type && course.name == @Select_course_name
          tmp<<course
        end
      end
      @course=tmp
    end
  end


  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses.paginate(page: params[:page], per_page: 7) if teacher_logged_in?
    @course=current_user.courses.paginate(page: params[:page], per_page: 7) if student_logged_in?
  end


  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end
end


