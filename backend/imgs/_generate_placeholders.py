#!/usr/bin/env python3
"""Generate clean placeholder product images for the BeeHive Online catalog.

These are tasteful, app-ready placeholders (category-coloured cards with the
product name), NOT real brand photos. Re-run to regenerate. Drop in real
product photos with the same filenames to replace any of them.
"""
import os
from PIL import Image, ImageDraw, ImageFont

OUT = os.path.dirname(os.path.abspath(__file__))
FONT_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FONT_REG = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
SIZE = 800

# Category palette: (top gradient, bottom gradient, accent for tag)
CATEGORIES = {
    "minuman":    ((0x1A, 0x73, 0xE8), (0x10, 0x4A, 0x9E), "Drinks"),
    "makanan":    ((0xF5, 0x9E, 0x0B), (0xC2, 0x73, 0x03), "Food"),
    "snack":      ((0xEF, 0x6C, 0x00), (0xB5, 0x3D, 0x00), "Snack"),
    "essentials": ((0x0E, 0x9F, 0x6E), (0x05, 0x6F, 0x4B), "Essentials"),
}

# (filename, display name, category)
PRODUCTS = [
    ("teh_pucuk.jpg",   "Teh Pucuk Harum",       "minuman"),
    ("aqua.jpg",        "Aqua 600ml",            "minuman"),
    ("ultra_milk.jpg",  "Ultra Milk Cokelat",    "minuman"),
    ("kopiko78.jpg",    "Kopiko 78 Latte",       "minuman"),
    ("le_minerale.jpg", "Le Minerale 600ml",     "minuman"),
    ("nasi_uduk.jpg",   "Nasi Uduk Box",         "makanan"),
    ("bakpao.jpg",      "Bakpao Ayam",           "makanan"),
    ("popmie.jpg",      "Pop Mie Rasa Baso",     "makanan"),
    ("roti_coklat.jpg", "Roti Coklat Sari Roti", "makanan"),
    ("chitato.jpg",     "Chitato Sapi Panggang", "snack"),
    ("silverqueen.jpg", "Silverqueen Chocolate", "snack"),
    ("roti_bakar.jpg",  "Roti Bakar Coklat Keju","snack"),
    ("bengbeng.jpg",    "Beng-Beng Share It",    "snack"),
    ("oreo.jpg",        "Oreo Vanilla 133g",     "snack"),
    ("tissue.jpg",      "Tissue Paseo Smart",    "essentials"),
    ("pulpen.jpg",      "Pulpen Snowman V-1",    "essentials"),
    ("pensil.jpg",      "Pensil 2B Faber",       "essentials"),
    ("rexona.jpg",      "Rexona Men Roll On",    "essentials"),
    ("buku_tulis.jpg",  "Buku Tulis Sinar Dunia","essentials"),
    ("penggaris.jpg",   "Penggaris Butterfly",   "essentials"),
]


def gradient(top, bottom):
    img = Image.new("RGB", (SIZE, SIZE), top)
    for y in range(SIZE):
        t = y / SIZE
        r = int(top[0] + (bottom[0] - top[0]) * t)
        g = int(top[1] + (bottom[1] - top[1]) * t)
        b = int(top[2] + (bottom[2] - top[2]) * t)
        ImageDraw.Draw(img).line([(0, y), (SIZE, y)], fill=(r, g, b))
    return img


def wrap(draw, text, font, max_w):
    words, lines, cur = text.split(), [], ""
    for w in words:
        trial = (cur + " " + w).strip()
        if draw.textlength(trial, font=font) <= max_w:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def make(fname, name, cat):
    top, bottom, tag = CATEGORIES[cat]
    img = gradient(top, bottom)
    d = ImageDraw.Draw(img, "RGBA")

    # Soft decorative circle (bee-ish accent)
    d.ellipse([SIZE - 230, -120, SIZE + 120, 230], fill=(255, 255, 255, 28))
    d.ellipse([-120, SIZE - 230, 230, SIZE + 120], fill=(0, 0, 0, 28))

    # White rounded "product chip" with the initial letter
    chip = SIZE // 3
    cx0, cy0 = (SIZE - chip) // 2, SIZE // 2 - chip
    d.rounded_rectangle([cx0, cy0, cx0 + chip, cy0 + chip], radius=48,
                        fill=(255, 255, 255, 235))
    initial = name[0].upper()
    fbig = ImageFont.truetype(FONT_BOLD, int(chip * 0.6))
    bb = d.textbbox((0, 0), initial, font=fbig)
    d.text((cx0 + (chip - (bb[2] - bb[0])) / 2 - bb[0],
            cy0 + (chip - (bb[3] - bb[1])) / 2 - bb[1]),
           initial, font=fbig, fill=bottom)

    # Category tag (top-left pill)
    ftag = ImageFont.truetype(FONT_BOLD, 30)
    tw = d.textlength(tag.upper(), font=ftag)
    d.rounded_rectangle([40, 40, 40 + tw + 48, 100], radius=30,
                        fill=(255, 255, 255, 235))
    d.text((64, 53), tag.upper(), font=ftag, fill=bottom)

    # Product name, wrapped, below the chip
    fname_font = ImageFont.truetype(FONT_BOLD, 52)
    lines = wrap(d, name, fname_font, SIZE - 120)
    y = cy0 + chip + 50
    for ln in lines:
        lw = d.textlength(ln, font=fname_font)
        # subtle shadow for legibility
        d.text(((SIZE - lw) / 2 + 2, y + 2), ln, font=fname_font, fill=(0, 0, 0, 80))
        d.text(((SIZE - lw) / 2, y), ln, font=fname_font, fill=(255, 255, 255, 255))
        y += 64

    # Brand footer
    ffoot = ImageFont.truetype(FONT_REG, 26)
    foot = "BeeHive Online"
    fw = d.textlength(foot, font=ffoot)
    d.text(((SIZE - fw) / 2, SIZE - 56), foot, font=ffoot, fill=(255, 255, 255, 170))

    img.save(os.path.join(OUT, fname), "JPEG", quality=88)


if __name__ == "__main__":
    for f, n, c in PRODUCTS:
        make(f, n, c)
        print("wrote", f)
    print(f"Done: {len(PRODUCTS)} images.")
