# Mirage brand

**Name.** Mirage. One word, always capitalised. The town is Dry Creek, the hero is Wren, the villain is the Dust King.

**Line.** The spring is real. Go and get it.

**Mark.** A cream sun over a far mesa, with two wavering lines of heat shimmer under it, on a terracotta tile (`icon.svg`). Flat, no figure, no text. Joshua Tree's own icon pipeline draws the dock tile from the same shapes (`tools/gen/restyle_icons.py`, the "mirage" entry).

**Wordmark.** MIRAGE in the game's own 5 by 7 pixel letters, ink with a terracotta drop shadow one half-pixel down and right. It is drawn by the game (`wordmark` in `user/mirage.c`), not set in a font.

**Colour.** From `tokens.css`:

| Token | Hex | Use |
|---|---|---|
| paper | #faf8f4 | page background, title card |
| ink | #1c1c1e | text, the wordmark |
| terra | #b5502c | the accent: the mark, buttons, Wren's scarf |
| sky | #74bdeb | the desert sky in the game |
| sand | #d9b26a | the town's ground |
| night | #141311 | dark mode, behind the game |

**Type.** The system font on the web. Inside Joshua Tree, Tree Sans for text and the pixel wordmark for the title.

**Pixel art.** 16 by 16 sprites (the Dust King is 32 by 32), a letter per pixel in the source, a dark outline round every figure. Each room has its own sky, rock and lip colours, and flat two-layer scenery with no gradients.

**Voice.** Plain words, short sentences, a little dry. The townsfolk talk like neighbours, not like a fantasy novel.
