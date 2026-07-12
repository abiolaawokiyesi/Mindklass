import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    outDir: "dist",
    // Raise the warning limit — MindKlass is a single large component by design.
    chunkSizeWarningLimit: 1500,
    rollupOptions: {
      output: {
        // Split third-party libraries into their own chunk, separate from
        // app code. This doesn't shrink the total download, but it lets the
        // browser fetch the vendor chunk and the app chunk in parallel, and
        // — more importantly — the vendor chunk's contents rarely change
        // between deploys, so returning visitors reuse it from cache instead
        // of re-downloading the whole bundle every time MindKlass.jsx changes.
        manualChunks: {
          vendor: ["react", "react-dom", "@supabase/supabase-js", "lucide-react"],
        },
      },
    },
  },
});
