# GlyphOutline
Rendering outlined font in Delphi without FreeType.

Yes, no FreeType, yay!

1. Glyphs are rendered in red (lum) and green (alpha) channels to be used for GL_LUMINANCE_ALPHA textures. You may change it to whatever you want.
2. I'm using QPixels instead of ScanLine - it's way more intuitive and just as fast. You can google it or write your own implementation with ScanLine.
3. Technically, outlining code may be used for outlining just anything.

Need some more optimisation and linting.

Oh, and you may find some comments somewhat offensive.
