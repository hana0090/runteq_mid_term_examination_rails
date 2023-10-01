class SignUpForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  attribute :email, :string
  attribute :password, :string
  attribute :password_confirmation, :string
  attribute :name, :string

  validates :password, length: { minimum: 3 }
  validates :password, confirmation: true
  with_options presence: true do
    validates :email, :password, :password_confirmation, :name
  end

  validate :email_is_not_taken_by_another
  validate :validate_github_name # Include GitHub nickname validation

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      user.save!
      Profile.create!(name: name, user: user)
    end
  rescue StandardError
    false
  end

  def user
    @user ||= User.new(email: email, password: password, password_confirmation: password_confirmation)
  end

  private

  def email_is_not_taken_by_another
    errors.add(:email, :taken, value: email) if User.exists?(email: email)
  end

  def validate_github_name
  
    url = URI.parse("https://github.com/#{name}")
    response = Net::HTTP.get_response(url)
  
    unless response.is_a?(Net::HTTPSuccess)
      errors.add(:base, "GitHubに存在するユーザー名しか登録できません")
    end
  end
end
