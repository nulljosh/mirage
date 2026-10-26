# Mirage

The landing and web build for Mirage, the desert platformer in Joshua Tree. The game's source of truth is `../joshuatree/user/mirage.c` and `mirage_core.h`; never copy them here.

- `./build.sh` compiles them to `landing/mirage.wasm` with Homebrew LLVM, and copies `brand/tokens.css` and `icon.svg` into `landing/`. Commit the built wasm so a deploy needs no joshuatree checkout.
- `./deploy.sh` builds, then `npx wrangler deploy` (Worker `mirage`, static assets from `landing/`, custom domain mirage.jaybulb.com). A push deploys nothing.
- The page runs the real game on a canvas directly under the tagline, with no frame around it. The game exports `mirage_start(w, h)`, `mirage_key(code, tick)` and `mirage_tick(tick)`; the page owns the loop at 100 ticks a second.
- Check a page change headless (Playwright in `../duke/scripts`), never in a browser on Joshua's screen.
- Design: `brand/BRAND.md` and `brand/tokens.css`. Paper, ink and terracotta, plus the game's sky and sand. Flat colours, the system font, no gradients, no teal or purple.
