# frozen_string_literal: true

module Api
  class CustomFontsController < ApiBaseController
    before_action :doorkeeper_authorize!, only: %i[index create destroy]

    def index
      custom_fonts = current_account.custom_fonts.order(:name)
      render json: custom_fonts.map { |f| custom_font_json(f) }
    end

    def create
      unless params[:font_file]
        return render json: { error: 'Font file is required' }, status: :bad_request
      end

      custom_font = current_account.custom_fonts.build(name: custom_font_params[:name])

      if custom_font.save
        font_file = params[:font_file]
        custom_font.font_file.attach(font_file)
        render json: custom_font_json(custom_font), status: :created
      else
        render json: { errors: custom_font.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      custom_font = current_account.custom_fonts.find_by!(uuid: params[:uuid])
      custom_font.destroy
      render json: { success: true }
    end

    private

    def custom_font_params
      params.require(:custom_font).permit(:name)
    end

    def custom_font_json(font)
      {
        uuid: font.uuid,
        name: font.name,
        created_at: font.created_at,
        size: font.font_file.attached? ? font.font_file.blob.byte_size : 0
      }
    end
  end
end
