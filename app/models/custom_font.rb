# frozen_string_literal: true

require 'fileutils'

# == Schema Information
#
# Table name: custom_fonts
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  uuid       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#  font_file  :text
#
# Indexes
#
#  index_custom_fonts_on_account_id                 (account_id)
#  index_custom_fonts_on_account_id_and_name       (account_id,name) UNIQUE
#  index_custom_fonts_on_uuid                      (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)

class CustomFont < ApplicationRecord
  belongs_to :account
  has_one_attached :font_file

  validates :name, presence: true, uniqueness: { scope: :account_id }
  validates :uuid, presence: true, uniqueness: true

  before_validation :set_uuid, on: :create

  scope :by_account, ->(account) { where(account_id: account.id) }

  def self.at_path(font_uuid, account = nil)
    # Returns the file path for the font to be used in PDF generation
    return nil unless account && font_uuid
    
    font = find_by(uuid: font_uuid, account_id: account.id)
    return nil unless font&.font_file&.attached?
    
    # Try to use the blob's local path if available (for disk storage)
    if font.font_file.blob.service.is_a?(ActiveStorage::Service::DiskService)
      return font.font_file.blob.service.path_for(font.font_file.key)
    end
    
    # For cloud storage, create a temporary file with proper cleanup
    # Store the temp files in a directory that persists for the request
    extension = font.font_file.blob.filename.extension.presence || 'ttf'
    temp_dir = Rails.root.join('tmp', 'custom_fonts')
    FileUtils.mkdir_p(temp_dir)
    
    # Use a stable filename based on the UUID to avoid creating duplicate files
    temp_path = temp_dir.join("#{font_uuid}.#{extension}")
    
    # Only write the file if it doesn't already exist
    unless File.exist?(temp_path)
      File.write(temp_path, font.font_file.blob.download)
    end
    
    temp_path.to_s
  rescue StandardError => e
    Rails.logger.error("Error getting custom font path: #{e.message}")
    nil
  end

  private

  def set_uuid
    self.uuid = SecureRandom.uuid
  end
end
