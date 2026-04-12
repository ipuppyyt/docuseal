# Custom Fonts Feature Implementation

## Overview

This implementation adds the ability to upload and use custom fonts in DocuSeal's text field editor. Users can now upload font files in various formats and select them from the font dropdown in the template builder.

## Components Added

### Database

- **Migration**: `db/migrate/20260328100000_create_custom_fonts.rb`
  - Creates `custom_fonts` table with fields for account_id, name, uuid, and Active Storage attachment

### Models

- **CustomFont** (`app/models/custom_font.rb`)
  - Belongs to Account
  - Has one attached font file
  - Validates file size (max 10MB)
  - Validates file format (TTF, OTF, WOFF, WOFF2, PFB)
  - Validates MIME type

- **Account** (updated)
  - Added `has_many :custom_fonts` relationship

### Controllers

- **CustomFontsController** (`app/controllers/custom_fonts_controller.rb`)
  - Handles "list", "create", and "delete" actions for custom fonts
  - Authenticated with user login
  - Validates font files before saving

- **Api::CustomFontsController** (`app/controllers/api/custom_fonts_controller.rb`)
  - Same functionality as web controller but for API requests
  - Supports OAuth with Doorkeeper

### Frontend

- **FontModal** (`app/javascript/template_builder/font_modal.vue`)
  - Updated to include custom fonts section
  - Displays uploaded fonts in dropdown
  - Allows uploading new fonts
  - Shows file size for each font
  - Allows deletion of custom fonts

### Backend Font Resolution

- **GenerateResultAttachments** (`lib/submissions/generate_result_attachments.rb`)
  - Updated to check for custom fonts by UUID
  - Falls back to default fonts if custom font not found
  - Handles font variants (bold, italic) for default fonts only

### Routes

- Added routes to `config/routes.rb`:
  - Web routes: `/custom_fonts` (index, create, destroy)
  - API routes: `/api/custom_fonts` (index, create, destroy)

## Features

### For Users

1. **Upload Custom Fonts**: Upload TTF, OTF, WOFF, or WOFF2 font files (max 10MB)
2. **Manage Fonts**: View list of uploaded fonts with file sizes
3. **Select Fonts**: Choose custom fonts from dropdown when editing text fields
4. **Delete Fonts**: Remove fonts that are no longer needed
5. **Persistent Fonts**: Fonts are stored per account and available across all templates

### For Administrators

1. Account-scoped font storage - each account has its own fonts
2. Font validation - only valid font files are accepted
3. File size limits - prevents excessive storage usage
4. Multiple font formats supported

## Database Changes

Run the migration:

```bash
bin/rails db:migrate
```

## Usage

### For End Users

1. Open a template for editing
2. Click on a text field to open font settings
3. Scroll to "Custom Fonts" section
4. Upload a new font by:
   - Entering a font name
   - Selecting a font file
   - Clicking "Upload"
5. Select the font from the dropdown
6. Click "Save"

### For API Users

```bash
# List custom fonts
GET /api/custom_fonts

# Upload a custom font
POST /api/custom_fonts
Content-Type: multipart/form-data
{
  "custom_font[name]": "My Custom Font",
  "font_file": <file>
}

# Delete a custom font
DELETE /api/custom_fonts/{uuid}
```

## Security Considerations

1. **File Type Validation**: Only allows font files (TTF, OTF, WOFF, WOFF2, PFB)
2. **File Size Limits**: Maximum 10MB per font
3. **MIME Type Checking**: Validates content type
4. **Account Scoping**: Fonts are scoped to accounts, preventing cross-account access
5. **Unique Naming**: Font names are unique per account
6. **Safe Font Resolution**: Falls back to default fonts if custom font fails to load

## Known Limitations

1. Font variants (bold, italic) are not supported for custom fonts
2. Custom fonts cannot be previewed in the UI in real-time
3. Font files must be embedded in PDF output (increases file size)
4. No font family name detection - uses filename as font name

## Future Enhancements

1. Font preview in the UI before selection
2. Support for font variants/styles
3. Font optimization/subsetting
4. Font family detection from SFNT names
5. Batch font upload
6. Font sharing between accounts (admin-only)
7. Font usage analytics
