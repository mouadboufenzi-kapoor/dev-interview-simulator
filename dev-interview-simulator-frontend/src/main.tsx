import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'

// Polices auto-hébergées via @fontsource (aucun appel Google Fonts — spec §6).
// Space Grotesk : textes + titres ; Space Mono : labels/numéros/badges/minuteur.
import '@fontsource/space-grotesk/400.css'
import '@fontsource/space-grotesk/500.css'
import '@fontsource/space-grotesk/700.css'
import '@fontsource/space-mono/400.css'
import '@fontsource/space-mono/700.css'

import './index.css'
import App from './App.tsx'
import { initTheme } from './utils/theme'

// Thème (palette + mode) appliqué avant le render → aucun flash de mauvais thème.
// Le script inline de index.html a déjà posé data-theme/data-mode ; cet appel
// est idempotent et couvre le cas où ce module chargerait avant ce script.
initTheme()

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
