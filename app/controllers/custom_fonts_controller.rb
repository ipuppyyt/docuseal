# frozen_string_literal: true

class CustomFontsController < ApplicationController
  before_action :authenticate_user!, except: %i[download]
  skip_authorization_check only: %i[index create destroy download]
  rescue_from StandardError, with: :handle_error

  MAX_FILE_SIZE = 10.megabytes
  ALLOWED_FORMATS = %w[ttf otf woff woff2 pfb].freeze

  def index
    unless current_account
      return render json: { error: 'Account not found' }, status: :not_found
    end
    
    Rails.logger.info("CustomFontsController#index - Account ID: #{current_account.id}")
    custom_fonts = current_account.custom_fonts.order(:name)
    Rails.logger.info("CustomFontsController#index - Found #{custom_fonts.count} fonts")
    render json: custom_fonts.map { |f| custom_font_json(f) }
  end

  def create
    unless current_account
      Rails.logger.error("CustomFontsController#create - No current_account")
      return render json: { error: 'Account not found' }, status: :not_found
    end
    
    unless params[:font_file]
      Rails.logger.error("CustomFontsController#create - No font_file in params")
      return render json: { error: 'Font file is required' }, status: :bad_request
    end

    file = params[:font_file]
    Rails.logger.info("CustomFontsController#create - Received file: #{file.original_filename}, size: #{file.size}")
    
    # Validate file size
    if file.size > MAX_FILE_SIZE
      Rails.logger.error("CustomFontsController#create - File too large: #{file.size} > #{MAX_FILE_SIZE}")
      return render json: { error: "Font file is too large (maximum #{MAX_FILE_SIZE / 1.megabyte}MB)" }, status: :bad_request
    end
    
    # Validate file extension
    extension = File.extname(file.original_filename).downcase.delete('.')
    unless extension.in?(ALLOWED_FORMATS)
      Rails.logger.error("CustomFontsController#create - Invalid extension: #{extension}")
      return render json: { error: "Font format not allowed. Allowed formats: #{ALLOWED_FORMATS.join(', ')}" }, status: :bad_request
    end

    font_name = custom_font_params[:name]&.strip.presence || File.basename(file.original_filename, '.*')
    Rails.logger.info("CustomFontsController#create - Font name: #{font_name}")
    
    # Validate name
    if font_name.length > 255
      Rails.logger.error("CustomFontsController#create - Font name too long")
      return render json: { error: 'Font name is too long (maximum 255 characters)' }, status: :bad_request
    end

    custom_font = current_account.custom_fonts.build(name: font_name)
    Rails.logger.info("CustomFontsController#create - Built custom_font, validating...")

    begin
      if custom_font.save!
        Rails.logger.info("CustomFontsController#create - Font saved successfully, ID: #{custom_font.id}, UUID: #{custom_font.uuid}")
        
        Rails.logger.info("CustomFontsController#create - Attaching file: #{file.original_filename}")
        custom_font.font_file.attach(file)
        Rails.logger.info("CustomFontsController#create - File attached, font_file.attached? = #{custom_font.font_file.attached?}")
        
        if custom_font.font_file.attached?
          Rails.logger.info("CustomFontsController#create - Font file confirmed attached, size: #{custom_font.font_file.byte_size}")
        else
          Rails.logger.error("CustomFontsController#create - Font file NOT attached after attach() call")
        end
        
        render json: custom_font_json(custom_font), status: :created
      end
    rescue => e
      Rails.logger.error("CustomFontsController#create - Exception during save: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      render json: { error: e.message, errors: custom_font.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    unless current_account
      return render json: { error: 'Account not found' }, status: :not_found
    end
    
    custom_font = current_account.custom_fonts.find_by!(uuid: params[:uuid])
    custom_font.destroy
    render json: { success: true }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Font not found' }, status: :not_found
  end

  def download
    custom_font = CustomFont.find_by!(uuid: params[:uuid])
    
    unless custom_font.font_file.attached?
      return render json: { error: 'Font file not found' }, status: :not_found
    end

    # Send the font file directly
    render_blob_inline_or_redirect(custom_font.font_file.blob)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Font not found' }, status: :not_found
  end

  private

  def render_blob_inline_or_redirect(blob)
    if blob.service.respond_to?(:path_for)
      # For disk service, redirect to the file path
      send_file blob.service.path_for(blob.key), 
                type: blob.content_type,
                filename: blob.filename.to_s,
                disposition: 'inline'
    else
      # For cloud services, redirect to signed URL
      redirect_to blob.service_url
    end
  end

  def custom_font_params
    params.permit(:name, :font_file)
  end

  def custom_font_json(font)
    {
      uuid: font.uuid,
      name: font.name,
      created_at: font.created_at,
      size: font.font_file.attached? ? font.font_file.blob.byte_size : 0,
      filename: font.font_file.attached? ? font.font_file.blob.filename.to_s : nil
    }
  end

  def handle_error(exception)
    Rails.logger.error("CustomFontsController error: #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n"))
    render json: { error: exception.message }, status: :internal_server_error
  end
end
