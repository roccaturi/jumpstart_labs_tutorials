class Article < ActiveRecord::Base
  has_many :comments
  has_many :taggings
  has_many :tags, through: :taggings

  def tag_list
    tags.join(', ')
  end

  def tag_list=(tags_string)
    tags = tags_string.split(',').collect {|t| t.downcase.strip}.uniq
    new_and_existing_tags = tags.collect { |t| Tag.find_or_create_by(name: t) }
    self.tags = new_and_existing_tags
  end
end
