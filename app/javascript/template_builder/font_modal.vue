<template>
  <div
    class="modal modal-open items-start !animate-none overflow-y-auto"
  >
    <div
      class="absolute top-0 bottom-0 right-0 left-0"
      @click.prevent="$emit('close')"
    />
    <div class="modal-box pt-4 pb-6 px-6 mt-20 max-h-none w-full max-w-2xl">
      <div class="flex justify-between items-center border-b pb-2 mb-2 font-medium">
        <span class="modal-title">
          {{ t('font') }} - {{ (defaultField ? (defaultField.title || field.title || field.name) : field.name) || buildDefaultName(field) }}
        </span>
        <a
          href="#"
          class="text-xl modal-close-button"
          @click.prevent="$emit('close')"
        >&times;</a>
      </div>
      <div class="mt-4">
        <div>
          <div class="flex items-center space-x-1.5">
            <span>
              <div class="dropdown modal-field-font-dropdown">
                <label
                  tabindex="0"
                  class="base-input flex items-center justify-between"
                  style="height: 32px; padding-right: 0; width: 120px"
                  :class="fonts.find((f) => f.value === preferences.font)?.class"
                >
                  <span style="margin-top: 1px">
                    {{ fonts.find((f) => f.value === preferences.font)?.label || 'Default' }}
                  </span>
                  <IconChevronDown
                    class="ml-2 mr-2 mt-0.5"
                    width="18"
                    height="18"
                  />
                </label>
                <div
                  tabindex="0"
                  class="dropdown-content p-0 mt-1 block z-10 menu shadow bg-base-100 border border-base-300 rounded-md w-52"
                >
                  <div
                    v-for="(font, index) in fonts"
                    :key="index"
                    :value="font.value"
                    :class="{ 'bg-base-300': preferences.font == font.value, [font.class]: true }"
                    class="hover:bg-base-300 px-2 py-1.5 cursor-pointer"
                    @click="[font.value ? preferences.font = font.value : delete preferences.font, closeDropdown()]"
                  >
                    {{ font.label }}
                  </div>
                </div>
              </div>
            </span>
            <span class="relative">
              <select
                class="select input-bordered bg-base-100 select-sm text-center pl-2"
                style="font-size: 16px; line-height: 12px; width: 86px; text-align-last: center;"
                @change="$event.target.value ? preferences.font_size = parseInt($event.target.value) : delete preferences.font_size"
              >
                <option
                  :selected="!preferences.font_size"
                  value=""
                >
                  Auto
                </option>
                <option
                  v-for="size in sizes"
                  :key="size"
                  :value="size"
                  :selected="size === preferences.font_size"
                >
                  {{ size }}
                </option>
              </select>
              <span
                class="border-l pl-1.5 absolute bg-base-100 bottom-0 pointer-events-none text-sm h-5"
                style="right: 13px; top: 6px"
              >
                pt
              </span>
            </span>
            <span class="flex">
              <div
                class="join"
                style="height: 32px"
              >
                <button
                  v-for="(type, index) in types"
                  :key="index"
                  class="btn btn-sm join-item bg-base-100 input-bordered hover:border-base-content/20 hover:bg-base-200/50 px-2"
                  :class="{ '!bg-base-300': preferences.font_type?.includes(type.value) }"
                  @click="setFontType(type.value)"
                >
                  <component :is="type.icon" />
                </button>
              </div>
            </span>
            <span class="flex">
              <div
                class="join"
                style="height: 32px"
              >
                <button
                  v-for="(align, index) in aligns"
                  :key="index"
                  class="btn btn-sm join-item bg-base-100 input-bordered hover:border-base-content/20 hover:bg-base-200/50 px-2"
                  :class="{ '!bg-base-300': preferences.align === align.value }"
                  @click="align.value && preferences.align != align.value ? preferences.align = align.value : delete preferences.align"
                >
                  <component :is="align.icon" />
                </button>
              </div>
            </span>
            <span class="flex">
              <div class="dropdown modal-field-font-dropdown">
                <label
                  tabindex="0"
                  class="cursor-pointer flex bg-base-100 border input-bordered rounded-md h-8 items-center justify-center px-1"
                  style="-webkit-appearance: none; -moz-appearance: none;"
                >
                  <component :is="valigns.find((v) => v.value === (preferences.valign || 'center'))?.icon" />
                </label>
                <div
                  tabindex="0"
                  class="dropdown-content p-0 mt-1 block z-10 menu shadow bg-base-100 border border-base-300 rounded-md"
                >
                  <div
                    v-for="(valign, index) in valigns"
                    :key="index"
                    :value="valign.value"
                    :class="{ 'bg-base-300': preferences.valign == valign.value }"
                    class="hover:bg-base-300 px-2 py-1.5 cursor-pointer"
                    @click="[valign.value ? preferences.valign = valign.value : delete preferences.valign, closeDropdown()]"
                  >
                    <component :is="valign.icon" />
                  </div>
                </div>
              </div>
            </span>
            <span>
              <select
                class="input input-bordered bg-base-100 input-sm text-lg rounded-md"
                style="-webkit-appearance: none; -moz-appearance: none; text-indent: 0px; text-overflow: ''; padding: 0px 6px; height: 32px"
                @change="$event.target.value ? preferences.color = $event.target.value : delete preferences.color"
              >
                <option
                  v-for="(color, index) in colors"
                  :key="index"
                  :value="color.value"
                  :selected="color.value == preferences.color"
                >
                  {{ color.label }}
                </option>
              </select>
            </span>
          </div>
        </div>
        <div class="mt-4">
          <div
            class="flex border border-base-content/20 rounded-xl bg-base-100 px-4 h-16 modal-field-font-preview"
            :style="{
              color: preferences.color || 'black',
              fontSize: (preferences.font_size || 11) + 'pt',
              ...previewFontStyle
            }"
            :class="textClasses"
          >
            <span
              contenteditable="true"
              class="outline-none whitespace-nowrap truncate"
            >
              {{ field.default_value || field.name || buildDefaultName(field) }}
            </span>
          </div>
          <div class="text-xs text-base-content/60 mt-1">
            Font: {{ currentFontDisplay }}
            <span v-if="preferences.font && customFonts.find(f => f.uuid === preferences.font)" class="ml-1">(custom font - will be applied in PDF)</span>
          </div>
        </div>
        <div class="divider my-3" />
        <div class="font-medium text-sm mb-3">{{ t('custom_fonts') || 'Custom Fonts' }}</div>
        <div class="bg-base-100 border border-base-300 rounded-lg p-3 mb-4">
          <div class="flex items-end gap-2 mb-3">
            <div class="flex-1">
              <label class="label label-text text-xs">Font name</label>
              <input
                v-model="newFontName"
                type="text"
                placeholder="Enter font name..."
                class="input input-bordered input-sm w-full"
              />
            </div>
            <div class="flex-1">
              <label class="label label-text text-xs">Font file (TTF, OTF, WOFF)</label>
              <input
                ref="fontFileInput"
                type="file"
                accept=".ttf,.otf,.woff,.woff2,.pfb"
                @change="onFileSelect"
                class="input input-bordered input-sm w-full file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-xs file:font-semibold file:bg-violet-50 file:text-violet-700"
              />
            </div>
            <button
              @click="uploadFont"
              :disabled="uploadingFont || !newFontName || !selectedFile"
              class="btn btn-sm btn-primary"
            >
              <span v-if="uploadingFont" class="loading loading-spinner loading-xs" />
              <span v-else>{{ t('upload') || 'Upload' }}</span>
            </button>
          </div>
          <div v-if="uploadError" class="alert alert-error alert-sm mb-3">
            {{ uploadError }}
          </div>
          <div v-if="customFonts.length" class="space-y-2">
            <div
              v-for="font in customFonts"
              :key="font.uuid"
              class="flex items-center justify-between bg-base-200 p-2 rounded"
            >
              <div class="text-sm">
                <div class="font-medium">{{ font.name }}</div>
                <div class="text-xs text-base-content/60">{{ formatBytes(font.size) }}</div>
              </div>
              <button
                @click="deleteFont(font.uuid)"
                class="btn btn-ghost btn-xs text-error"
              >
                ✕
              </button>
            </div>
          </div>
          <div v-else class="text-xs text-base-content/60">
            No custom fonts uploaded yet
          </div>
        </div>
        <div class="mt-4">
          <button
            class="base-button w-full modal-save-button"
            @click.prevent="saveAndClose"
          >
            {{ t('save') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { IconChevronDown, IconBold, IconItalic, IconAlignLeft, IconAlignRight, IconAlignCenter, IconAlignBoxCenterTop, IconAlignBoxCenterBottom, IconAlignBoxCenterMiddle } from '@tabler/icons-vue'

export default {
  name: 'FontModal',
  components: {
    IconChevronDown
  },
  inject: ['t', 'template'],
  props: {
    field: {
      type: Object,
      required: true
    },
    defaultField: {
      type: Object,
      required: false,
      default: null
    },
    editable: {
      type: Boolean,
      required: false,
      default: true
    },
    buildDefaultName: {
      type: Function,
      required: true
    }
  },
  emits: ['close', 'save'],
  data () {
    return {
      preferences: {},
      customFonts: [],
      newFontName: '',
      selectedFile: null,
      uploadingFont: false,
      uploadError: ''
    }
  },
  computed: {
    allFonts () {
      const defaultFonts = [
        { value: null, label: 'Default' },
        { value: 'Times', label: 'Times', class: 'font-times' },
        { value: 'Courier', label: 'Courier', class: 'font-courier' }
      ]
      
      const customFontItems = (this.customFonts || []).map(f => {
        console.log('Adding custom font to list:', f.name, f.uuid)
        return {
          value: f.uuid,
          label: f.name,
          class: ''
        }
      })
      
      const all = [...defaultFonts, ...customFontItems]
      console.log('All fonts available:', all)
      return all
    },
    fonts () {
      return this.allFonts
    },
    types () {
      return [
        { icon: IconBold, value: 'bold' },
        { icon: IconItalic, value: 'italic' }
      ]
    },
    aligns () {
      return [
        { icon: IconAlignLeft, value: 'left' },
        { icon: IconAlignCenter, value: 'center' },
        { icon: IconAlignRight, value: 'right' }
      ]
    },
    valigns () {
      return [
        { icon: IconAlignBoxCenterTop, value: 'top' },
        { icon: IconAlignBoxCenterMiddle, value: 'center' },
        { icon: IconAlignBoxCenterBottom, value: 'bottom' }
      ]
    },
    sizes () {
      return [...Array(23).keys()].map(i => i + 6)
    },
    colors () {
      return [
        { label: '⬛', value: 'black' },
        { label: '⬜', value: 'white' },
        { label: '🟦', value: 'blue' },
        { label: '🟥', value: 'red' }
      ]
    },
    textClasses () {
      return {
        'font-courier': this.preferences.font === 'Courier',
        'font-times': this.preferences.font === 'Times',
        'justify-center': this.preferences.align === 'center',
        'justify-start': this.preferences.align === 'left',
        'justify-end': this.preferences.align === 'right',
        'items-center': !this.preferences.valign || this.preferences.valign === 'center',
        'items-start': this.preferences.valign === 'top',
        'items-end': this.preferences.valign === 'bottom',
        'bg-black': this.preferences.color === 'white',
        'font-bold': ['bold_italic', 'bold'].includes(this.preferences.font_type),
        italic: ['bold_italic', 'italic'].includes(this.preferences.font_type)
      }
    },
    previewFontStyle () {
      const styles = {}
      
      if (this.preferences.font === 'Courier') {
        styles.fontFamily = 'Courier, monospace'
      } else if (this.preferences.font === 'Times') {
        styles.fontFamily = 'Times, serif'
      } else if (this.preferences.font && this.customFonts.find(f => f.uuid === this.preferences.font)) {
        // Apply custom font
        styles.fontFamily = `'custom-font-${this.preferences.font}', sans-serif`
      }
      
      return styles
    },
    currentFontDisplay () {
      if (!this.preferences.font) {
        return 'Default'
      }
      const font = this.fonts.find(f => f.value === this.preferences.font)
      return font?.label || 'Custom Font'
    },
    keys () {
      return ['font_type', 'font_size', 'color', 'align', 'valign', 'font']
    }
  },
  created () {
    this.preferences = this.keys.reduce((acc, key) => {
      acc[key] = this.field.preferences?.[key]

      return acc
    }, {})
    console.log('FontModal created, loading custom fonts...')
    this.loadCustomFonts()
  },
  mounted () {
    this.injectCustomFontStyles()
  },
  methods: {
    closeDropdown () {
      this.$el.getRootNode().activeElement.blur()
    },
    onFileSelect (event) {
      this.selectedFile = event.target.files[0] || null
      console.log('File selected:', this.selectedFile?.name, 'Size:', this.selectedFile?.size)
    },
    setFontType (value) {
      if (value === 'bold') {
        if (this.preferences.font_type === 'bold') {
          delete this.preferences.font_type
        } else if (this.preferences.font_type === 'italic') {
          this.preferences.font_type = 'bold_italic'
        } else if (this.preferences.font_type === 'bold_italic') {
          this.preferences.font_type = 'italic'
        } else {
          this.preferences.font_type = value
        }
      }

      if (value === 'italic') {
        if (this.preferences.font_type === 'italic') {
          delete this.preferences.font_type
        } else if (this.preferences.font_type === 'bold') {
          this.preferences.font_type = 'bold_italic'
        } else if (this.preferences.font_type === 'bold_italic') {
          this.preferences.font_type = 'bold'
        } else {
          this.preferences.font_type = value
        }
      }
    },
    async loadCustomFonts () {
      try {
        console.log('Fetching custom fonts from /custom_fonts...')
        const response = await fetch('/custom_fonts')
        console.log('Custom fonts response status:', response.status)
        
        if (!response.ok) {
          console.error('Failed to load custom fonts, status:', response.status)
          const text = await response.text()
          console.error('Response body:', text)
          this.customFonts = []
          return
        }
        
        const data = await response.json()
        console.log('Custom fonts loaded:', data)
        this.customFonts = Array.isArray(data) ? data : []
        console.log('Custom fonts set to:', this.customFonts)
        
        // Inject @font-face styles after fonts are loaded
        this.$nextTick(() => {
          this.injectCustomFontStyles()
        })
      } catch (err) {
        console.error('Error loading custom fonts:', err)
        this.customFonts = []
      }
    },
    injectCustomFontStyles () {
      const styleId = 'custom-fonts-style'
      let styleEl = document.getElementById(styleId)
      
      if (!styleEl) {
        styleEl = document.createElement('style')
        styleEl.id = styleId
        document.head.appendChild(styleEl)
      }
      
      // Generate @font-face rules for each custom font
      const fontFaceRules = this.customFonts.map(font => {
        const downloadUrl = `/custom_fonts/${font.uuid}/download`
        // Detect font format from filename
        const ext = font.filename ? font.filename.split('.').pop().toLowerCase() : 'ttf'
        let formatStrings = []
        
        if (['ttf', 'otf'].includes(ext)) {
          formatStrings = [`url('${downloadUrl}') format('truetype')`]
        } else if (ext === 'woff') {
          formatStrings = [`url('${downloadUrl}') format('woff')`]
        } else if (ext === 'woff2') {
          formatStrings = [`url('${downloadUrl}') format('woff2')`]
        } else if (ext === 'pfb') {
          formatStrings = [`url('${downloadUrl}') format('opentype')`]
        } else {
          // Fallback: try all formats
          formatStrings = [
            `url('${downloadUrl}') format('woff2')`,
            `url('${downloadUrl}') format('woff')`,
            `url('${downloadUrl}') format('truetype')`,
            `url('${downloadUrl}') format('opentype')`
          ]
        }
        
        return `
          @font-face {
            font-family: 'custom-font-${font.uuid}';
            src: ${formatStrings.join(', ')};
          }
        `
      }).join('\n')
      
      styleEl.textContent = fontFaceRules
      console.log('Injected @font-face styles for', this.customFonts.length, 'fonts')
    },
    async uploadFont () {
      if (!this.newFontName || !this.selectedFile) {
        return
      }

      const file = this.selectedFile
      const formData = new FormData()
      formData.append('name', this.newFontName)
      formData.append('font_file', file)

      this.uploadingFont = true
      this.uploadError = ''

      try {
        console.log('Uploading font:', this.newFontName, 'File:', file.name, 'Size:', file.size)
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
        const response = await fetch('/custom_fonts', {
          method: 'POST',
          body: formData,
          headers: csrfToken ? { 'X-CSRF-Token': csrfToken } : {}
        })

        console.log('Upload response status:', response.status)
        
        if (response.ok) {
          const newFont = await response.json()
          console.log('Upload successful, font:', newFont)
          this.customFonts.push(newFont)
          this.newFontName = ''
          this.selectedFile = null
          this.$refs.fontFileInput.value = ''
          // Reload fonts to refresh the list
          console.log('Reloading fonts after upload...')
          await this.loadCustomFonts()
        } else {
          const error = await response.json()
          console.error('Upload failed:', error)
          this.uploadError = error.error || error.errors || 'Failed to upload font'
        }
      } catch (err) {
        console.error('Upload exception:', err)
        this.uploadError = 'Error uploading font: ' + err.message
      } finally {
        this.uploadingFont = false
      }
    },
    async deleteFont (uuid) {
      if (!confirm('Delete this font?')) {
        return
      }

      try {
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
        const response = await fetch(`/custom_fonts/${uuid}`, {
          method: 'DELETE',
          headers: csrfToken ? { 'X-CSRF-Token': csrfToken } : {}
        })

        if (response.ok) {
          this.customFonts = this.customFonts.filter(f => f.uuid !== uuid)
          // Reset font preference if it was the deleted font
          if (this.preferences.font === uuid) {
            delete this.preferences.font
          }
        } else {
          const error = await response.json()
          alert('Failed to delete font: ' + (error.error || 'Unknown error'))
        }
      } catch (err) {
        alert('Error deleting font: ' + err.message)
        console.error('Delete error:', err)
      }
    },
    formatBytes (bytes) {
      if (bytes === 0) return '0 Bytes'
      const k = 1024
      const sizes = ['Bytes', 'KB', 'MB']
      const i = Math.floor(Math.log(bytes) / Math.log(k))
      return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
    },
    saveAndClose () {
      this.field.preferences ||= {}

      this.keys.forEach((key) => delete this.field.preferences[key])

      Object.assign(this.field.preferences, this.preferences)

      this.$emit('save')
      this.$emit('close')
    }
  }
}
</script>
