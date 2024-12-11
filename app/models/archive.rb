class Archive < ApplicationRecord
  has_many_attached :images
  has_one_attached :primary_image

  validates :name, presence: true
  validates :description, presence: true
  validate :youtube_links_must_be_valid

  private

  def youtube_links_must_be_valid
    youtube_links.each do |link|
      unless link.match?(/\Ahttps:\/\/(www\.)?youtube\.com\/.+\z/)
        errors.add(:youtube_links, "#{link} is not a valid YouTube URL")
      end
    end
  end
end
