class AddYoutubeLinksToArchivesAndCollaborations < ActiveRecord::Migration[7.1]
  def change
    add_column :archives, :youtube_links, :text, array: true, default: []
    add_column :collaborations, :youtube_links, :text, array: true, default: []
  end
end
