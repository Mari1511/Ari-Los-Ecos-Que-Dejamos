"""Sprites chibi estilo RPG: hoja 3 columnas (pasos) x 4 filas (abajo, izquierda, derecha, arriba), 24x32 c/u."""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
import numpy as np
from PIL import Image
from scipy import ndimage

OUT = os.path.join(REPO, 'assets') + '/' + 'chars/'
os.makedirs(OUT, exist_ok=True)
FW, FH = 24, 32
OUTLINE = (24, 14, 22)
SKIN = (250, 205, 175)
SKIN_D = (222, 168, 140)
EYE = (40, 20, 30)


def C(t):
    return np.array(t, dtype=np.uint8)


class Frame:
    def __init__(self):
        self.a = np.zeros((FH, FW, 4), np.uint8)

    def px(self, x, y, c):
        if 0 <= x < FW and 0 <= y < FH:
            self.a[y, x, :3] = c
            self.a[y, x, 3] = 255

    def rect(self, x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.px(x, y, c)

    def ell(self, cx, cy, rx, ry, c, cond=None):
        for y in range(FH):
            for x in range(FW):
                if ((x - cx + 0.5) / rx) ** 2 + ((y - cy + 0.5) / ry) ** 2 <= 1.0:
                    if cond is None or cond(x, y):
                        self.px(x, y, c)

    def finish(self):
        a = self.a
        m = a[:, :, 3] > 0
        ring = ndimage.binary_dilation(m) & ~m
        a[ring, :3] = OUTLINE
        a[ring, 3] = 255
        return a


def shade(c, k):
    return tuple(max(0, min(255, int(v * k))) for v in c)


def draw_char(spec, d, step):
    """d: 0 abajo, 1 izquierda, 2 derecha(=espejo), 3 arriba. step: 0 quieto, 1 pie A, 2 pie B."""
    f = Frame()
    side = d in (1, 2)
    hair = spec['hair']
    top = spec['top']
    sleeve = spec.get('sleeve', top)
    legs = spec['legs']
    shoes = spec.get('shoes', (35, 30, 35))
    bob = 1 if step else 0
    oy = spec.get('oy', 0)
    # piernas
    ly = 25 + oy
    if not side:
        la = 1 if step == 1 else 0
        lb = 1 if step == 2 else 0
        f.rect(8, ly, 10, 30 - la, legs)
        f.rect(13, ly, 15, 30 - lb, legs)
        f.rect(8, 30 - la, 10, 31 - la, shoes)
        f.rect(13, 30 - lb, 15, 31 - lb, shoes)
        if spec.get('stripes'):
            for y in range(ly, 30, 2):
                f.rect(8, y, 10, y, (240, 240, 240))
                f.rect(13, y, 15, y, (240, 240, 240))
    else:
        if step == 0:
            f.rect(10, ly, 13, 30, legs)
            f.rect(10, 30, 13, 31, shoes)
        else:
            fx = 7 if step == 1 else 8
            bx = 14 if step == 1 else 13
            f.rect(fx, ly, fx + 2, 30, legs)
            f.rect(bx, ly, bx + 2, 30, shade(legs, 0.8))
            f.rect(fx - 1, 30, fx + 2, 31, shoes)
            f.rect(bx, 30, bx + 3, 31, shoes)
        if spec.get('stripes'):
            for y in range(ly, 30, 2):
                for x in range(6, 18):
                    if f.a[y, x, 3] and tuple(f.a[y, x, :3]) != shoes:
                        f.px(x, y, (240, 240, 240))
    # cuerpo
    by = 16 + oy - bob * 0
    if not side:
        f.rect(7, by, 16, 25 + oy + spec.get('skirt', 0), top)
        f.rect(7, by, 7, 25 + oy, shade(top, 0.85))
        f.rect(16, by, 16, 25 + oy, shade(top, 0.75))
        # brazos
        sa = 1 if step == 1 else 0
        sb = 1 if step == 2 else 0
        f.rect(5, by + 1, 6, 23 + oy - sa, sleeve)
        f.rect(17, by + 1, 18, 23 + oy - sb, shade(sleeve, 0.85))
        f.rect(5, 24 + oy - sa, 6, 24 + oy - sa, SKIN)
        f.rect(17, 24 + oy - sb, 18, 24 + oy - sb, SKIN_D)
    else:
        f.rect(8, by, 15, 25 + oy + spec.get('skirt', 0), top)
        f.rect(15, by, 15, 25 + oy, shade(top, 0.75))
        sw = {0: 0, 1: -2, 2: 2}[step]
        f.rect(11 + sw // 2, by + 1, 12 + sw // 2, 23 + oy, shade(sleeve, 0.9))
        f.px(11 + sw, 24 + oy, SKIN)
        f.px(12 + sw, 24 + oy, SKIN)
    if spec.get('body_fn'):
        spec['body_fn'](f, d, step, oy)
    # cabeza
    hx, hy = (12, 9) if not side else (11, 9)
    f.ell(hx, hy + 1, 8, 8, hair)
    if d == 0:
        f.ell(12, 12, 6, 5.5, SKIN, lambda x, y: y >= 8)
        f.rect(6, 15, 17, 15, SKIN)
        # flequillo
        for x in range(5, 19):
            yb = 9 + (1 if x % 3 == 0 else 0)
            for y in range(4, yb):
                f.px(x, y, hair)
        # ojos
        for ex in (8, 14):
            f.rect(ex, 11, ex + 1, 13, EYE)
            f.px(ex, 11, (255, 255, 255))
        f.px(11, 15, shade(SKIN, 0.85))
        f.px(12, 15, shade(SKIN, 0.85))
        f.px(7, 14, (240, 150, 150))
        f.px(16, 14, (240, 150, 150))
    elif side:
        f.ell(8, 12, 5, 5.5, SKIN, lambda x, y: y >= 8 and x <= 11)
        for x in range(3, 12):
            for y in range(3, 9 + (1 if x % 3 == 0 else 0)):
                f.px(x, y, hair)
        f.rect(5, 11, 6, 13, EYE)
        f.px(5, 11, (255, 255, 255))
        f.px(4, 14, (240, 150, 150))
    # brillo del cabello
    for x in range(hx - 4, hx + 1):
        f.px(x, 3 if d != 0 else 3, shade(hair, 1.35))
    if spec.get('head_fn'):
        spec['head_fn'](f, d, step)
    a = f.finish()
    if d == 2:
        a = a[:, ::-1].copy()
    return a


# --------------------------------------------------------------- accesorios

def ari_head(f, d, step):
    hair = (240, 120, 125)
    # melena hasta los hombros
    if d == 0:
        f.rect(3, 9, 5, 17, hair)
        f.rect(18, 9, 20, 17, hair)
        f.px(6, 9, (220, 60, 60)); f.px(7, 8, (220, 60, 60)); f.px(7, 9, (40, 20, 20))  # mariquita
    elif d in (1, 2):
        f.rect(11, 8, 19, 17, hair)
        f.px(13, 6, (220, 60, 60))
    else:
        f.rect(4, 9, 19, 17, hair)
    for (x, y) in [(5, 1), (18, 1)] if d != 1 and d != 2 else [(14, 1), (8, 1)]:
        f.ell(x, y + 1, 2.6, 2.6, (25, 22, 28))


def ari_body(f, d, step, oy):
    if d != 3:
        f.rect(7 if d == 0 else 8, 16, 16 if d == 0 else 15, 17, (245, 240, 235))
    if d == 0:
        for y in (19, 21, 23):
            f.px(12, y, (60, 10, 20))
    f.rect(7 if d != 1 and d != 2 else 8, 26, 16 if d != 1 and d != 2 else 15, 26, (240, 230, 230))


def edd_head(f, d, step):
    white = (238, 235, 225)
    spot = (30, 28, 32)
    f.ell(12 if d in (0, 3) else 11, 8, 9, 7.5, white, lambda x, y: y <= 9)
    spots = [(6, 5), (15, 4), (10, 2), (18, 7)] if d != 3 else [(8, 4), (14, 6), (11, 2)]
    for (x, y) in spots:
        f.rect(x, y, x + 2, y + 1, spot)
    if d == 0:
        f.rect(6, 9, 17, 9, (110, 160, 90))
        for (x0, s) in [(1, 1), (22, -1)]:
            f.px(x0, 3, (220, 215, 205)); f.px(x0, 2, (220, 215, 205)); f.px(x0 + s, 4, (220, 215, 205)); f.px(x0 + s, 5, (220, 215, 205))
    elif d in (1, 2):
        f.rect(3, 9, 11, 9, (110, 160, 90))
        f.px(13, 1, (220, 215, 205)); f.px(13, 2, (220, 215, 205)); f.px(12, 3, (220, 215, 205))
    else:
        for (x0, s) in [(1, 1), (22, -1)]:
            f.px(x0, 3, (220, 215, 205)); f.px(x0 + s, 4, (220, 215, 205))
        f.rect(6, 15, 17, 16, (110, 160, 90))


def edd_body(f, d, step, oy):
    if d == 0:
        for y in (18, 20, 22):
            f.px(12, y, (90, 60, 10))
        f.rect(7, 16, 16, 16, (200, 140, 20))


def damian_body(f, d, step, oy):
    if d == 0:
        f.rect(10, 16, 13, 25, (140, 140, 145))
        f.rect(7, 25, 16, 25, (230, 225, 215))


def vera_head(f, d, step):
    hair = (45, 32, 58)
    if d == 0:
        f.rect(3, 9, 5, 24, hair)
        f.rect(18, 9, 20, 24, hair)
        f.px(5, 13, (230, 190, 80)); f.px(18, 13, (230, 190, 80))
    elif d in (1, 2):
        f.rect(11, 8, 18, 24, hair)
    else:
        f.rect(4, 9, 19, 24, hair)


def vera_body(f, d, step, oy):
    if d == 0:
        f.rect(10, 16, 13, 24, (245, 245, 240))
        f.rect(13, 21, 14, 23, (240, 150, 170))  # teléfono


def nico_head(f, d, step):
    if d == 0:
        for ex in (7, 13):
            f.rect(ex, 10, ex + 3, 10, (50, 50, 55))
            f.rect(ex, 14, ex + 3, 14, (50, 50, 55))
            f.px(ex, 11, (50, 50, 55)); f.px(ex + 3, 11, (50, 50, 55))
    elif d in (1, 2):
        f.rect(4, 10, 7, 10, (50, 50, 55))
        f.rect(4, 14, 7, 14, (50, 50, 55))


def nico_body(f, d, step, oy):
    if d == 0:
        f.rect(11, 20, 13, 23, (25, 25, 30))  # teléfono
    if d == 3:
        f.rect(8, 14, 15, 16, (75, 85, 50))  # capucha


def rivas_head(f, d, step):
    if d == 0:
        for ex in (7, 13):
            f.rect(ex, 10, ex + 3, 10, (40, 40, 45))
            f.rect(ex, 13, ex + 3, 13, (40, 40, 45))
        f.rect(10, 10, 13, 10, (40, 40, 45))
    elif d in (1, 2):
        f.rect(4, 10, 7, 10, (40, 40, 45))


def rivas_body(f, d, step, oy):
    if d == 0:
        f.rect(11, 16, 12, 23, (30, 40, 85))
        f.rect(9, 16, 10, 17, (235, 235, 235))
        f.rect(13, 16, 14, 17, (235, 235, 235))


def claudia_head(f, d, step):
    hair = (110, 70, 45)
    if d == 0:
        f.rect(3, 9, 5, 15, hair)
        f.rect(18, 9, 20, 15, hair)
        for y in range(15, 23):
            f.px(19 - (y % 2), y, shade(hair, 0.85 if y % 2 else 1.1))
        nico_head(f, d, step)
    elif d in (1, 2):
        f.rect(11, 8, 18, 15, hair)
        nico_head(f, d, step)
    else:
        f.rect(4, 9, 19, 15, hair)
        for y in range(15, 23):
            f.px(12 - (y % 2), y, shade(hair, 0.85 if y % 2 else 1.1))


def claudia_body(f, d, step, oy):
    if d == 0:
        f.rect(9, 19, 14, 22, (210, 175, 120))  # carpeta


def helena_head(f, d, step):
    f.ell(12 if d != 1 and d != 2 else 14, 1, 3, 2.5, (160, 160, 165))
    rivas_head(f, d, step)


def profe1_body(f, d, step, oy):
    pass


SPECS = {
    'ari': dict(hair=(240, 120, 125), top=(160, 22, 34), legs=(30, 26, 30), stripes=True, skirt=1,
                head_fn=ari_head, body_fn=ari_body),
    'edd': dict(hair=(110, 160, 90), top=(242, 182, 32), legs=(70, 100, 160), head_fn=edd_head, body_fn=edd_body),
    'damian': dict(hair=(72, 46, 34), top=(32, 32, 38), sleeve=(232, 226, 214), legs=(48, 48, 58), body_fn=damian_body),
    'vera': dict(hair=(45, 32, 58), top=(216, 190, 162), legs=(60, 58, 80), head_fn=vera_head, body_fn=vera_body),
    'nico': dict(hair=(172, 160, 138), top=(92, 102, 60), legs=(60, 60, 72), head_fn=nico_head, body_fn=nico_body),
    'rivas': dict(hair=(36, 36, 42), top=(62, 62, 68), sleeve=(235, 235, 235), legs=(40, 40, 48), head_fn=rivas_head, body_fn=rivas_body),
    'claudia': dict(hair=(110, 70, 45), top=(130, 160, 222), legs=(80, 70, 92), head_fn=claudia_head, body_fn=claudia_body),
    'helena': dict(hair=(165, 165, 170), top=(112, 30, 46), legs=(50, 40, 50), head_fn=helena_head),
    'profe1': dict(hair=(30, 28, 30), top=(172, 200, 236), legs=(36, 36, 46)),
    'profe2': dict(hair=(205, 205, 205), top=(150, 150, 155), legs=(40, 40, 50)),
}


def build(name, spec):
    sheet = np.zeros((FH * 4, FW * 3, 4), np.uint8)
    for d in range(4):
        for s in range(3):
            step = [1, 0, 2][s]
            sheet[d * FH:(d + 1) * FH, s * FW:(s + 1) * FW] = draw_char(spec, d, step)
    Image.fromarray(sheet, 'RGBA').save(OUT + name + '.png')
    return sheet


if __name__ == '__main__':
    sheets = [build(n, s) for n, s in SPECS.items()]
    W = sum(s.shape[1] + 4 for s in sheets)
    prev = Image.new('RGBA', (W, FH * 4), (70, 80, 90, 255))
    x = 0
    for s in sheets:
        prev.alpha_composite(Image.fromarray(s, 'RGBA'), (x, 0))
        x += s.shape[1] + 4
    prev.resize((W * 3, FH * 12), Image.NEAREST).save(os.path.join(HERE, 'preview_sprites_preview.png'))
    print('ok')
