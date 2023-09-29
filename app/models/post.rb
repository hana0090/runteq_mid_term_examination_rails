class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :post_tags
  has_many :tags, through: :post_tags

  validates :title, presence: true
  validates :body, presence: true

  
  # タグを設定するためのカスタムメソッド
  def tag_names=(names)
    tag_names_array = names.split(',').map(&:strip).uniq
    self.tags = tag_names_array.map { |name| Tag.find_or_create_by(name: name) }
  end

  # タグを取得するためのカスタムメソッド
  def tag_names
    tags.map(&:name).join(',')
  end
  
end

