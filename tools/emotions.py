"""Genera retratos con emociones pintando pixel por pixel sobre la base."""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
import numpy as np
from PIL import Image, ImageFilter

OUT = os.path.join(REPO, 'assets') + '/' + 'portraits/'
os.makedirs(OUT, exist_ok=True)

LINE = (40, 14, 22)
TEAR = (150, 205, 255)
TEAR_HI = (235, 248, 255)
WHITE = (252, 250, 246)
BLUSH = (238, 120, 140)
MOUTH_IN = (120, 30, 45)

CHARS = {
    # eyes (x0,y0,x1,y1), mouth (cx,cy), half width, skin sample, crop bottom, emotions
    'ari': dict(eyes=[(45, 56, 63, 74), (81, 56, 100, 74)], mouth=(72, 85), hw=4, skin=(68, 70), crop=150,
                emo=['neutral', 'feliz', 'rie', 'triste', 'llora', 'miedo', 'enojada', 'sombra', 'sonrojada']),
    'edd': dict(eyes=[(21, 58, 36, 72), (54, 58, 70, 72)], mouth=(47, 79), hw=4, skin=(40, 77), crop=135,
                emo=['neutral', 'feliz', 'triste', 'llora', 'miedo', 'enojado', 'serio']),
    'damian': dict(eyes=[(53, 55, 68, 63), (78, 54, 93, 62)], mouth=(76, 70), hw=5, skin=(70, 66), crop=165,
                   emo=['neutral', 'burla', 'enojado', 'miedo']),
    'vera': dict(eyes=[(50, 59, 66, 67), (82, 59, 97, 67)], mouth=(75, 76), hw=5, skin=(74, 69), crop=165,
                 emo=['neutral', 'burla', 'enojada', 'miedo']),
    'nico': dict(eyes=[(54, 61, 66, 68), (81, 61, 93, 68)], mouth=(77, 79), hw=6, skin=(75, 73), crop=165,
                 emo=['neutral', 'triste', 'miedo', 'llora']),
    'rivas': dict(eyes=[(58, 59, 69, 64), (80, 59, 91, 64)], mouth=(76, 77), hw=6, skin=(72, 50), crop=165,
                  emo=['neutral', 'sombra', 'enojado', 'serio']),
    'claudia': dict(eyes=[(52, 64, 65, 74), (82, 63, 96, 73)], mouth=(75, 82), hw=4, skin=(75, 77), crop=165,
                    emo=['neutral', 'triste', 'llora', 'feliz']),
}


def px(a, x, y, c):
    if 0 <= y < a.shape[0] and 0 <= x < a.shape[1] and a[y, x, 3] > 0:
        a[y, x, :3] = c


def line(a, x0, y0, x1, y1, c, th=1):
    n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in range(n + 1):
        x = round(x0 + (x1 - x0) * i / n)
        y = round(y0 + (y1 - y0) * i / n)
        for t in range(th):
            px(a, x, y + t, c)


def clear_mouth(a, d, skin):
    cx, cy = d['mouth']
    hw = d['hw']
    for y in range(cy - 2, cy + 3):
        for x in range(cx - hw - 2, cx + hw + 3):
            px(a, x, y, skin)


def mouth(a, d, skin, kind):
    cx, cy = d['mouth']
    hw = d['hw']
    clear_mouth(a, d, skin)
    if kind == 'smile':
        for dx in range(-hw, hw + 1):
            y = cy + round(1.4 * (1 - (dx / hw) ** 2)) - 1
            px(a, cx + dx, y, LINE)
    elif kind == 'grin':
        for dx in range(-hw, hw + 1):
            y = cy + round(1.6 * (1 - (dx / hw) ** 2)) - 1
            px(a, cx + dx, y, LINE)
            if abs(dx) < hw - 1:
                px(a, cx + dx, y - 1, WHITE)
        px(a, cx - hw - 1, cy - 2, LINE)
        px(a, cx + hw + 1, cy - 2, LINE)
    elif kind == 'laugh':
        w = max(2, hw - 1)
        for dx in range(-w, w + 1):
            px(a, cx + dx, cy - 1, LINE)
            depth = round(2.5 * (1 - (dx / (w + 0.5)) ** 2))
            for k in range(depth):
                px(a, cx + dx, cy + k, MOUTH_IN)
            px(a, cx + dx, cy + depth, LINE)
    elif kind == 'frown':
        for dx in range(-hw, hw + 1):
            y = cy - round(1.2 * (1 - (dx / hw) ** 2)) + 1
            px(a, cx + dx, y, LINE)
    elif kind == 'flat':
        w = max(2, round(hw * 0.6))
        line(a, cx - w, cy, cx + w, cy, LINE)
    elif kind == 'open':
        w = max(1, round(hw * 0.45))
        for dy in range(-1, 3):
            ww = w if dy in (0, 1) else w - 1
            for dx in range(-ww, ww + 1):
                edge = dy in (-1, 2) or abs(dx) == ww
                px(a, cx + dx, cy + dy, LINE if edge else MOUTH_IN)
    elif kind == 'shout':
        w = hw
        line(a, cx - w, cy - 1, cx + w, cy - 1, LINE)
        for dx in range(-w + 1, w):
            px(a, cx + dx, cy, WHITE)
            px(a, cx + dx, cy + 1, MOUTH_IN)
        line(a, cx - w + 1, cy + 2, cx + w - 1, cy + 2, LINE)


def brows(a, d, kind, col=LINE):
    for i, (x0, y0, x1, y1) in enumerate(d['eyes']):
        inner_is_right = i == 0
        yb = y0 - 3
        w = x1 - x0
        if kind == 'sad':
            yi, yo = yb - 2, yb + 1
        elif kind == 'angry':
            yi, yo = yb + 3, yb - 1
        else:
            continue
        xa, xb = x0 + 1, x1 - 1
        if inner_is_right:
            line(a, xa, yo, xb, yi, col, 2)
        else:
            line(a, xa, yi, xb, yo, col, 2)


def eyes_closed(a, d, skin, arc='up'):
    for (x0, y0, x1, y1) in d['eyes']:
        for y in range(y0 + 1, y1 + 1):
            for x in range(x0, x1 + 1):
                px(a, x, y, skin)
        ym = (y0 + y1) // 2 + 1
        xc = (x0 + x1) // 2
        if arc == 'up':
            line(a, x0 + 1, ym + 1, xc, ym - 2, LINE, 2)
            line(a, xc, ym - 2, x1 - 1, ym + 1, LINE, 2)
        else:
            line(a, x0 + 1, ym - 1, xc, ym + 1, LINE, 2)
            line(a, xc, ym + 1, x1 - 1, ym - 1, LINE, 2)


def eyes_fear(a, d):
    for (x0, y0, x1, y1) in d['eyes']:
        top = y0 + max(2, (y1 - y0) // 4)
        for y in range(top, y1):
            for x in range(x0 + 1, x1):
                px(a, x, y, WHITE)
        line(a, x0 + 1, y1, x1 - 1, y1, LINE)
        cx, cy = (x0 + x1) // 2, (top + y1) // 2
        for dy in range(0, 2):
            for dx in range(0, 2):
                px(a, cx + dx, cy + dy, LINE)


def eyes_half(a, d, skin):
    """Párpado bajado (enojo/serio)."""
    for (x0, y0, x1, y1) in d['eyes']:
        cut = y0 + max(2, (y1 - y0) * 2 // 5)
        for y in range(y0, cut):
            for x in range(x0, x1 + 1):
                px(a, x, y, skin)
        line(a, x0, cut, x1, cut, LINE, 2)


def tears(a, d, stream=True):
    for i, (x0, y0, x1, y1) in enumerate(d['eyes']):
        line(a, x0 + 2, y1 - 1, x1 - 2, y1 - 1, TEAR_HI)
        if stream:
            tx = x1 - 3 if i == 0 else x0 + 3
            L = max(6, (y1 - y0))
            for k in range(L):
                px(a, tx, y1 + 1 + k, TEAR)
                if k < L - 2:
                    px(a, tx + (1 if i == 0 else -1), y1 + 1 + k, TEAR_HI if k % 3 == 0 else TEAR)


def blush(a, d):
    for (x0, y0, x1, y1) in d['eyes']:
        y = y1 + 3
        for k in range(3):
            xx = x0 + 2 + k * 4
            line(a, xx + 1, y, xx, y + 2, BLUSH)


def sweat(a, d):
    x0, y0, x1, y1 = d['eyes'][1]
    sx, sy = x1 + 3, y0 - 4
    for k, w in enumerate([0, 1, 1, 2, 2, 1]):
        for dx in range(-w, w + 1):
            px(a, sx + dx, sy + k, TEAR if abs(dx) < w or w == 0 else (90, 150, 220))


def shadow(a, d, eye_col=(255, 255, 255)):
    ybot = max(e[3] for e in d['eyes']) + 2
    for y in range(0, ybot + 1):
        fade = 1.0 if y < ybot - 4 else (ybot - y) / 4
        k = 1 - 0.68 * fade
        a[y, :, 0] = (a[y, :, 0] * k + 20 * (1 - k) * 0.3).astype(np.uint8)
        a[y, :, 1] = (a[y, :, 1] * k).astype(np.uint8)
        a[y, :, 2] = (a[y, :, 2] * k + 30 * (1 - k) * 0.3).astype(np.uint8)
    for (x0, y0, x1, y1) in d['eyes']:
        cx, cy = (x0 + x1) // 2, (y0 + y1) // 2 + 1
        px(a, cx, cy, eye_col)
        px(a, cx + 1, cy, eye_col)


def make(name, d, emo):
    base = np.array(Image.open(os.path.join(HERE, 'base', f'base_{name}.png')).convert('RGBA'))
    a = base.copy()
    skin = tuple(int(v) for v in base[d['skin'][1], d['skin'][0], :3])
    if emo in ('feliz',):
        mouth(a, d, skin, 'smile')
        if name in ('ari', 'claudia'):
            blush(a, d)
    elif emo == 'rie':
        eyes_closed(a, d, skin, 'up')
        mouth(a, d, skin, 'laugh')
        blush(a, d)
    elif emo == 'burla':
        mouth(a, d, skin, 'grin')
        eyes_half(a, d, skin)
    elif emo == 'triste':
        brows(a, d, 'sad')
        mouth(a, d, skin, 'frown')
        tears(a, d, stream=False)
    elif emo == 'llora':
        brows(a, d, 'sad')
        mouth(a, d, skin, 'open')
        tears(a, d, stream=True)
    elif emo == 'miedo':
        eyes_fear(a, d)
        mouth(a, d, skin, 'open')
        sweat(a, d)
    elif emo in ('enojado', 'enojada'):
        eyes_half(a, d, skin)
        brows(a, d, 'angry')
        mouth(a, d, skin, 'shout' if name in ('damian', 'vera', 'rivas') else 'frown')
    elif emo == 'serio':
        eyes_half(a, d, skin)
        mouth(a, d, skin, 'flat')
    elif emo == 'sombra':
        if name == 'rivas':
            mouth(a, d, skin, 'smile')
            shadow(a, d, (255, 60, 60))
        else:
            mouth(a, d, skin, 'flat')
            shadow(a, d)
    elif emo == 'sonrojada':
        blush(a, d)
        brows(a, d, 'sad')
        mouth(a, d, skin, 'flat')
    img = Image.fromarray(a, 'RGBA').crop((0, 0, a.shape[1], d['crop']))
    img = img.crop(img.getbbox())
    img.save(OUT + f'{name}_{emo}.png')
    return img


if __name__ == '__main__':
    rows = []
    for name, d in CHARS.items():
        rows.append([make(name, d, e) for e in d['emo']])
    W = max(sum(i.width + 6 for i in r) for r in rows)
    H = sum(max(i.height for i in r) + 6 for r in rows)
    sheet = Image.new('RGBA', (W, H), (50, 50, 70, 255))
    y = 0
    for r in rows:
        x = 0
        for i in r:
            sheet.alpha_composite(i, (x, y))
            x += i.width + 6
        y += max(i.height for i in r) + 6
    sheet.resize((W * 2, H * 2), Image.NEAREST).save(os.path.join(HERE, 'preview_emotions_sheet.png'))
    print('ok', W, H)
