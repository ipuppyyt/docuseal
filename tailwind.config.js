module.exports = {
  plugins: [
    require('daisyui')
  ],
  daisyui: {
    themes: [
      {
        docuseal: {
          'color-scheme': 'light',
          primary: '#e4e0e1',
          secondary: '#ef9fbc',
          accent: '#eeaf3a',
          neutral: '#291334',
          'base-100': '#faf7f5',
          'base-200': '#efeae6',
          'base-300': '#e7e2df',
          'base-content': '#291334',
          '--rounded-btn': '1.9rem',
          '--tab-border': '2px',
          '--tab-radius': '.5rem'
        },
        'docuseal-dark': {
          'color-scheme': 'dark',
          primary: '#fafafa',
          'primary-content': '#09090b',
          secondary: '#ef9fbc',
          accent: '#eeaf3a',
          neutral: '#27272a',
          'base-100': '#09090b',
          'base-200': '#18181b',
          'base-300': '#27272a',
          'base-content': '#e4e4e7',
          '--rounded-btn': '1.9rem',
          '--tab-border': '2px',
          '--tab-radius': '.5rem'
        }
      }
    ]
  }
}
