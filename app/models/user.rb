class User < ActiveRecord::Base

  before_save :downcase_email  #回调方法  在用户对象存入数据库之前把电子邮件地址转换为小写字母形式
  attr_accessor :remember_token
  validates :name, presence: true, length: {maximum: 50}
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true

  has_many :grades
  has_many :courses, through: :grades

  has_many :teaching_courses, class_name: "Course", foreign_key: :teacher_id

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}

  #1. The ability to save a securely hashed password_digest attribute to the database
  #2. A pair of virtual attributes (password and password_confirmation), including presence validations upon object creation and a validation requiring that they match
  #3. An authenticate method that returns the user when the password is correct (and false otherwise)
  has_secure_password
  # has_secure_password automatically adds an authenticate method to the corresponding model objects.
  # This method determines if a given password is valid for a particular user by computing its digest and comparing the result to password_digest in the database.

  # Returns the hash digest of the given string.
  #
  # 返回指定字符串打哈系摘要 2
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  #添加生成记忆令牌 1
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  #把记忆令牌和用户关联起来 3
  def user_remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  #佢忘记用户
  def user_forget
    update_attribute(:remember_digest, nil)
  end

  # Returns true if the given token matches the digest.
  # 如果指定打令牌和摘要匹配，返回true
  def user_authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  private

  def downcase_email
    self.email = email.downcase
  end

end
