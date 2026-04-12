# frozen_string_literal: true

namespace :cleanup do
  desc 'Remove old temporary custom font files'
  task fonts: :environment do
    temp_dir = Rails.root.join('tmp', 'custom_fonts')
    
    if Dir.exist?(temp_dir)
      # Remove files older than 24 hours
      Dir.glob("#{temp_dir}/*").each do |file|
        if File.file?(file) && Time.now - File.mtime(file) > 86400
          File.delete(file)
          puts "Deleted old font file: #{file}"
        end
      end
    end
  end
end
