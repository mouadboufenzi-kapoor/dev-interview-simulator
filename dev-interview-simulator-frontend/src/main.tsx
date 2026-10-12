import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import { resolveInitialTheme, applyTheme } from './utils/theme'

// Dark mode : thème appliqué avant le render → pas de flash blanc en mode sombre.
applyTheme(resolveInitialTheme())

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
