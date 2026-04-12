# frozen_string_literal: true

class CreateCustomFonts < ActiveRecord::Migration[8.1]
  def change
    create_table :custom_fonts do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :uuid, null: false
      t.timestamps
      
      t.index [:account_id, :name], unique: true
      t.index :uuid, unique: true
    end

    add_column :custom_fonts, :font_file, :text # For Active Storage attachment
  end
end
