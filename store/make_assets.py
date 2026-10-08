from PIL import Image, ImageDraw, ImageFont

BG = (21, 101, 192)      # mavi
FG = (255, 255, 255)

def font(size):
    for p in ("C:/Windows/Fonts/arialbd.ttf", "C:/Windows/Fonts/arial.ttf"):
        try:
            return ImageFont.truetype(p, size)
        except OSError:
            pass
    return ImageFont.load_default()

def centered(draw, w, h, text, size, dy=0):
    f = font(size)
    box = draw.textbbox((0, 0), text, font=f)
    draw.text(((w - (box[2] - box[0])) / 2 - box[0], (h - (box[3] - box[1])) / 2 - box[1] + dy), text, font=f, fill=FG)

# Uygulama simgesi 512x512 (Play simgeyi köşelerden kendisi yuvarlar, kare ve tam dolu olmalı)
icon = Image.new("RGB", (512, 512), BG)
d = ImageDraw.Draw(icon)
centered(d, 512, 512, "HT", 240)
icon.save("icon_512.png")

# Öne çıkan grafik 1024x500
fg = Image.new("RGB", (1024, 500), BG)
d = ImageDraw.Draw(fg)
centered(d, 1024, 500, "Hello Test", 140, dy=-40)
centered(d, 1024, 500, "Merhaba Dünya", 56, dy=90)
fg.save("feature_graphic_1024x500.png")
print("ok")
