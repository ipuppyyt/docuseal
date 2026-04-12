export default class ThemeToggle extends HTMLElement {
  connectedCallback() {
    const input = this.querySelector('input[type="checkbox"]')
    if (input) {
      input.checked = document.documentElement.getAttribute('data-theme') === 'docuseal-dark'
      
      input.addEventListener('change', (e) => {
        const newTheme = e.target.checked ? 'docuseal-dark' : 'docuseal'
        document.documentElement.setAttribute('data-theme', newTheme)
        document.cookie = `theme=${newTheme};path=/;max-age=31536000` // 1 year
      })
    }
  }
}
