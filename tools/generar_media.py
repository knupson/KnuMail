"""Genera el logo, los íconos y el avatar de CurseForge de KnuMail.

Uso desde la raíz del repo:  python tools/generar_media.py
Salida: media/*.tga (32 bits, sin compresión, para el juego) y tools/preview/*.png.

Misma identidad que KnuUI (E:/Repositorios/Personal/KnuUI/tools/generar_media.py):
hexágono ámbar de knunet.com, pero con un sobre en lugar de la K.
"""
import math
import pathlib

from PIL import Image, ImageDraw, ImageFilter, ImageFont

BASE = pathlib.Path(__file__).resolve().parent.parent
MEDIA = BASE / "media"
PREVIEW = BASE / "tools" / "preview"

# Paleta knunet.com (igual que KnuUI): amber-hi, amber-dim, amber, bg, text.
AMBAR_CLARO = (255, 192, 106)
AMBAR_OSCURO = (176, 116, 40)
AMBAR = (255, 168, 46)
FONDO = (17, 12, 8)
TEXTO = (236, 217, 189)

FUENTE = r"C:\Windows\Fonts\bahnschrift.ttf"


def fuente_condensada(tam):
    f = ImageFont.truetype(FUENTE, tam)
    try:
        f.set_variation_by_name("Bold Condensed")
    except Exception:
        pass
    return f


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def degradado(size, c1, c2, angulo=35):
    w, h = size
    img = Image.new("RGBA", size)
    px = img.load()
    rad = math.radians(angulo)
    dx, dy = math.cos(rad), math.sin(rad)
    largo = abs(w * dx) + abs(h * dy)
    for y in range(h):
        for x in range(w):
            t = ((x * dx + y * dy) / largo) % 1.0
            px[x, y] = (*lerp(c1, c2, t), 255)
    return img


def franjas(ancho, alto, paso):
    img = Image.new("RGBA", (ancho, alto), (*FONDO, 255))
    d = ImageDraw.Draw(img)
    for x in range(-alto, ancho + alto, paso):
        d.polygon([(x, alto), (x + paso // 2, alto), (x + paso // 2 + alto, 0), (x + alto, 0)], fill=(*AMBAR, 255))
    return img


def hexagono(cx, cy, r, rot=90):
    return [(cx + r * math.cos(math.radians(rot + 60 * i)), cy + r * math.sin(math.radians(rot + 60 * i))) for i in range(6)]


def sobre(L, cx, cy):
    """Máscara de un sobre: contorno grueso más la solapa en V."""
    m = Image.new("L", (L, L), 0)
    d = ImageDraw.Draw(m)
    w, h = L * 0.44, L * 0.30
    g = L * 0.05  # grosor del trazo
    x0, y0, x1, y1 = cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2
    d.rectangle([x0, y0, x1, y1], fill=255)
    d.rectangle([x0 + g, y0 + g, x1 - g, y1 - g], fill=0)
    # Solapa: dos trazos desde las esquinas superiores hasta el centro.
    d.line([(x0 + g * 0.5, y0 + g * 0.5), (cx, cy + h * 0.12), (x1 - g * 0.5, y0 + g * 0.5)], fill=255, width=int(g), joint="curve")
    return m


def emblema(lado):
    s = 4
    L = lado * s
    cx = cy = L / 2
    r = L * 0.46

    borde = Image.new("L", (L, L), 0)
    d = ImageDraw.Draw(borde)
    d.polygon(hexagono(cx, cy, r), fill=255)
    d.polygon(hexagono(cx, cy, r * 0.84), fill=0)

    relleno = Image.new("L", (L, L), 0)
    ImageDraw.Draw(relleno).polygon(hexagono(cx, cy, r * 0.84), fill=255)

    capa = Image.new("RGBA", (L, L), (0, 0, 0, 0))
    capa.paste(Image.new("RGBA", (L, L), (*FONDO, 235)), (0, 0), relleno)
    grad = degradado((L, L), AMBAR_CLARO, AMBAR_OSCURO)
    capa.paste(grad, (0, 0), borde)
    capa.paste(Image.new("RGBA", (L, L), (*TEXTO, 255)), (0, 0), sobre(L, cx, cy))

    brillo = Image.new("RGBA", (L, L), (0, 0, 0, 0))
    brillo.paste(grad, (0, 0), borde)
    brillo = brillo.filter(ImageFilter.GaussianBlur(L * 0.03))
    return Image.alpha_composite(brillo, capa).resize((lado, lado), Image.LANCZOS)


def logo(ancho=512, alto=256, marca="KNU", acento="MAIL", lema="WOW FOREVER · KNUNET"):
    s = 2
    W, H = ancho * s, alto * s
    lienzo = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    em = emblema(int(H * 0.78)).resize((int(H * 0.78), int(H * 0.78)), Image.LANCZOS)
    lienzo.alpha_composite(em, (int(W * 0.03), (H - em.height) // 2))

    tx = int(W * 0.03) + em.width + int(W * 0.03)
    d = ImageDraw.Draw(lienzo)
    disponible = W - tx - int(W * 0.04)
    tam = int(H * 0.42)
    while d.textlength(marca + acento, font=fuente_condensada(tam)) > disponible:
        tam -= 4
    fuente = fuente_condensada(tam)

    caja_m = d.textbbox((0, 0), marca, font=fuente, anchor="ls")
    caja_a = d.textbbox((0, 0), acento, font=fuente, anchor="ls")
    y = H // 2 + (caja_m[3] - caja_m[1]) // 2
    ax = tx + caja_m[2] - caja_m[0]

    sombra = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ds = ImageDraw.Draw(sombra)
    ds.text((tx + 6, y + 6), marca, font=fuente, fill=(0, 0, 0, 200), anchor="ls")
    ds.text((ax + 6, y + 6), acento, font=fuente, fill=(0, 0, 0, 200), anchor="ls")
    lienzo.alpha_composite(sombra.filter(ImageFilter.GaussianBlur(8)))

    d.text((tx, y), marca, font=fuente, fill=(*TEXTO, 255), anchor="ls")
    mascara = Image.new("L", (W, H), 0)
    ImageDraw.Draw(mascara).text((ax, y), acento, font=fuente, fill=255, anchor="ls")
    lienzo.paste(degradado((W, H), AMBAR_CLARO, AMBAR, 0), (0, 0), mascara)

    ancho_marca = ax + caja_a[2] - caja_a[0] - tx
    sub_y = y + int(H * 0.07)
    alto_f = max(int(H * 0.035), 6)
    lienzo.alpha_composite(franjas(ancho_marca, alto_f, alto_f * 2), (tx, sub_y))

    tam = int(H * 0.085)
    while d.textlength(lema, font=ImageFont.truetype(FUENTE, tam)) > ancho_marca:
        tam -= 2
    d.text((tx, sub_y + int(H * 0.06)), lema, font=ImageFont.truetype(FUENTE, tam), fill=(*TEXTO, 190), anchor="lt")
    return lienzo.resize((ancho, alto), Image.LANCZOS)


def avatar(lado=400):
    """Avatar cuadrado para CurseForge: emblema sobre el fondo oscuro de knunet."""
    img = Image.new("RGBA", (lado, lado), (*FONDO, 255))
    em = emblema(int(lado * 0.86))
    img.alpha_composite(em, ((lado - em.width) // 2, (lado - em.height) // 2))
    return img


def banner(ancho=1200, alto=400):
    """Imagen ancha para la descripción de CurseForge: logo sobre fondo oscuro."""
    img = Image.new("RGBA", (ancho, alto), (*FONDO, 255))
    lg = logo(int(alto * 2), alto)
    img.alpha_composite(lg, ((ancho - lg.width) // 2, 0))
    return img


def guardar(img, nombre, tga=True):
    MEDIA.mkdir(parents=True, exist_ok=True)
    PREVIEW.mkdir(parents=True, exist_ok=True)
    if tga:
        img.save(MEDIA / f"{nombre}.tga", compression=None)
    img.save(PREVIEW / f"{nombre}.png")
    print("ok", nombre, img.size)


if __name__ == "__main__":
    guardar(emblema(256), "icono")                 # lista de AddOns (IconTexture)
    guardar(emblema(64), "icono64")                # botón del buzón / opciones
    guardar(logo(), "logo")                        # ventana de opciones
    guardar(avatar(), "avatar", tga=False)         # avatar del proyecto en CurseForge
    guardar(banner(), "banner", tga=False)         # cabecera de la descripción en CurseForge
