import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  base: "/m3uPlaylistEditor",
  plugins: [react()],
  build: {
    rollupOptions: {
      input: {
        index: resolve(__dirname, 'index.html'),
        main: resolve(__dirname, 'src/main.tsx'),
        privacy: resolve(__dirname, 'privacy.html'),
        'privacy/main': resolve(__dirname, 'src/privacy/main.tsx'),
      },
    },
  },
})

