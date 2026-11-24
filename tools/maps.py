"""Tileset pixel art (16x16) inspirado en las fotos de la universidad + mapas.
Genera assets/maps/<id>.png (fondo), <id>_over.png (capa encima de personajes) y maps.json."""
import json
import os
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
import random
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.join(REPO, 'assets') + '/' + 'maps/'
os.makedirs(ROOT, exist_ok=True)
T = 16
FLOORS = set('.,:;')
WALK_EXTRA = set()


def shade(c, k):
    return tuple(max(0, min(255, int(v * k))) for v in c[:3])


class Tile:
    def __init__(self, seed=0):
        self.im = Image.new('RGBA', (T, T), (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.im)
        self.r = random.Random(seed)

    def rect(self, x0, y0, x1, y1, c):
        self.d.rectangle([x0, y0, x1, y1], fill=c)

    def px(self, x, y, c):
        self.d.point((x, y), fill=c)

    def line(self, x0, y0, x1, y1, c):
        self.d.line([x0, y0, x1, y1], fill=c)


# ------------------------------------------------------------------ pisos

def floor_ceramic(seed):
    t = Tile(seed)
    base = (214, 213, 205)
    t.rect(0, 0, 15, 15, base)
    for _ in range(7):
        t.px(t.r.randrange(1, 15), t.r.randrange(1, 15), (200, 199, 191))
    for _ in range(3):
        t.px(t.r.randrange(1, 15), t.r.randrange(1, 15), (226, 225, 218))
    t.line(0, 15, 15, 15, (172, 171, 165))
    t.line(15, 0, 15, 15, (172, 171, 165))
    t.line(0, 0, 14, 0, (228, 227, 221))
    return t.im


def floor_wood(seed):
    t = Tile(seed)
    for row in range(4):
        y0 = row * 4
        c = (156, 108, 66) if (row + seed) % 2 == 0 else (146, 100, 61)
        t.rect(0, y0, 15, y0 + 3, c)
        t.line(0, y0 + 3, 15, y0 + 3, (112, 76, 46))
        sx = (seed * 5 + row * 7) % 16
        t.line(sx, y0, sx, y0 + 2, (112, 76, 46))
        t.px((sx + 6) % 16, y0 + 1, (170, 122, 78))
    return t.im


def floor_carpet(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (104, 40, 48))
    for y in range(16):
        for x in range(16):
            if (x + y) % 4 == 0:
                t.px(x, y, (92, 34, 42))
    return t.im


def floor_concrete(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (112, 114, 120))
    for _ in range(14):
        c = (100, 102, 108) if t.r.random() < 0.6 else (124, 126, 132)
        t.px(t.r.randrange(16), t.r.randrange(16), c)
    if seed % 7 == 0:
        x = t.r.randrange(3, 12)
        t.line(x, 2, x + 2, 7, (90, 92, 98))
        t.line(x + 2, 7, x + 1, 12, (90, 92, 98))
    return t.im


# ------------------------------------------------------------------ paredes

PEACH = (226, 166, 124)
PEACH_D = (204, 146, 108)


def wall_upper(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, PEACH)
    t.rect(0, 0, 15, 2, (236, 233, 224))   # plafón
    t.line(0, 3, 15, 3, (150, 110, 84))
    for _ in range(4):
        t.px(t.r.randrange(16), t.r.randrange(5, 16), PEACH_D)
    return t.im


def wall_lower(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, PEACH)
    for _ in range(4):
        t.px(t.r.randrange(16), t.r.randrange(0, 11), PEACH_D)
    t.rect(0, 12, 15, 15, (120, 88, 74))
    t.line(0, 12, 15, 12, (150, 112, 94))
    return t.im


def void(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (16, 14, 20))
    return t.im


def window_upper(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 2, (236, 233, 224))
    t.rect(0, 3, 15, 15, (150, 152, 158))
    t.rect(1, 4, 14, 15, (26, 32, 52))
    t.line(3 + seed % 4, 15, 9 + seed % 4, 5, (52, 62, 92))
    t.px(4 + seed % 6, 7, (200, 190, 120))  # luz lejana
    return t.im


def window_lower(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (150, 152, 158))
    t.rect(1, 0, 14, 9, (26, 32, 52))
    t.line(2 + seed % 4, 9, 6 + seed % 4, 0, (52, 62, 92))
    t.rect(0, 10, 15, 11, (190, 192, 196))
    t.rect(0, 12, 15, 15, (120, 88, 74))
    return t.im


def board_upper(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, PEACH)
    t.rect(0, 0, 15, 2, (236, 233, 224))
    t.rect(0, 4, 15, 15, (182, 184, 190))
    t.rect(0, 5, 15, 15, (242, 242, 238))
    for _ in range(3):
        y = t.r.randrange(7, 14)
        x = t.r.randrange(0, 8)
        t.line(x, y, x + t.r.randrange(3, 8), y, (200, 60, 70) if t.r.random() < 0.6 else (60, 80, 180))
    return t.im


def board_lower(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, PEACH)
    t.rect(0, 0, 15, 6, (242, 242, 238))
    t.rect(0, 7, 15, 8, (160, 162, 168))
    t.rect(0, 12, 15, 15, (120, 88, 74))
    return t.im


def door_upper(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, PEACH)
    t.rect(0, 0, 15, 2, (236, 233, 224))
    t.rect(1, 4, 14, 15, (70, 72, 80))
    t.rect(2, 5, 13, 15, (120, 84, 58))
    t.rect(5, 7, 10, 12, (36, 44, 62))
    return t.im


def door_lower(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (70, 72, 80))
    t.rect(2, 0, 13, 15, (120, 84, 58))
    t.rect(11, 6, 12, 7, (220, 200, 120))
    t.line(2, 15, 13, 15, (60, 40, 30))
    return t.im


def door_bottom(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (16, 14, 20))
    t.rect(1, 0, 14, 15, (52, 46, 44))
    t.rect(2, 0, 13, 3, (90, 82, 76))
    return t.im


def door_side(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (16, 14, 20))
    t.rect(3, 0, 12, 15, (60, 52, 48))
    t.rect(3, 0, 12, 1, (110, 100, 90))
    return t.im


def locker_upper(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (236, 233, 224))
    t.rect(0, 3, 15, 15, (92, 112, 130))
    t.line(7, 3, 7, 15, (60, 74, 88))
    t.line(15, 3, 15, 15, (60, 74, 88))
    for y in (6, 8, 10):
        t.line(2, y, 5, y, (60, 74, 88))
        t.line(10, y, 13, y, (60, 74, 88))
    return t.im


def locker_lower(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (92, 112, 130))
    t.line(7, 0, 7, 11, (60, 74, 88))
    t.line(15, 0, 15, 11, (60, 74, 88))
    t.rect(5, 3, 5, 6, (190, 190, 190))
    t.rect(13, 3, 13, 6, (190, 190, 190))
    t.rect(0, 12, 15, 15, (60, 70, 80))
    return t.im


def locker_ari_upper(seed):
    im = locker_upper(seed)
    d = ImageDraw.Draw(im)
    d.rectangle([2, 4, 6, 15], fill=(140, 70, 90))
    d.point((4, 8), fill=(230, 60, 60))
    return im


def locker_ari_lower(seed):
    im = locker_lower(seed)
    d = ImageDraw.Draw(im)
    d.rectangle([0, 0, 6, 11], fill=(140, 70, 90))
    d.rectangle([5, 3, 5, 6], fill=(190, 190, 190))
    return im


def shelf_upper(seed, books=True):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (92, 60, 38))
    t.rect(0, 0, 15, 1, (70, 44, 28))
    for row in (2, 9):
        x = 1
        while x < 15:
            w = t.r.randrange(1, 3)
            h = t.r.randrange(4, 7)
            c = (t.r.randrange(60, 200), t.r.randrange(40, 150), t.r.randrange(40, 160))
            t.rect(x, row + 6 - h, x + w - 1, row + 5, c)
            x += w + (1 if t.r.random() < 0.2 else 0)
        t.rect(0, row + 6, 15, row + 6, (64, 40, 24))
    return t.im


def shelf_lower(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (92, 60, 38))
    x = 1
    while x < 15:
        w = t.r.randrange(1, 3)
        h = t.r.randrange(4, 7)
        c = (t.r.randrange(60, 200), t.r.randrange(40, 150), t.r.randrange(40, 160))
        t.rect(x, 8 - h, x + w - 1, 7, c)
        x += w
    t.rect(0, 8, 15, 8, (64, 40, 24))
    t.rect(0, 12, 15, 15, (64, 40, 24))
    return t.im


def metal_upper(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (60, 60, 66))
    for row in (4, 11):
        t.rect(0, row, 15, row, (140, 140, 148))
        bx = t.r.randrange(0, 6)
        t.rect(bx, row - 5, bx + 7, row - 1, (150, 118, 80))
        t.line(bx, row - 3, bx + 7, row - 3, (120, 92, 60))
    t.line(0, 0, 0, 15, (150, 150, 158))
    t.line(15, 0, 15, 15, (150, 150, 158))
    return t.im


def metal_lower(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (60, 60, 66))
    t.rect(0, 6, 15, 6, (140, 140, 148))
    t.rect(2, 1, 9, 5, (150, 118, 80))
    t.line(0, 0, 0, 11, (150, 150, 158))
    t.line(15, 0, 15, 11, (150, 150, 158))
    t.rect(0, 12, 15, 15, (50, 50, 56))
    return t.im


def file_upper(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (236, 233, 224))
    t.rect(0, 3, 15, 15, (128, 132, 138))
    t.rect(1, 5, 14, 9, (110, 114, 120))
    t.rect(6, 6, 9, 7, (190, 190, 196))
    t.rect(1, 11, 14, 15, (110, 114, 120))
    return t.im


def file_lower(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (128, 132, 138))
    t.rect(1, 1, 14, 5, (110, 114, 120))
    t.rect(6, 2, 9, 3, (190, 190, 196))
    t.rect(1, 7, 14, 11, (110, 114, 120))
    t.rect(0, 12, 15, 15, (90, 92, 98))
    return t.im


def banner_upper(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (232, 230, 214))
    t.rect(0, 0, 15, 2, (236, 233, 224))
    t.rect(0, 4, 15, 15, (30, 110, 70))
    t.line(0, 5, 15, 5, (220, 230, 220))
    return t.im


def banner_lower(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (30, 110, 70))
    t.line(0, 9, 15, 9, (220, 230, 220))
    t.rect(0, 10, 15, 15, (40, 40, 44))
    return t.im


def stage(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (96, 62, 40))
    for y in (3, 7, 11, 15):
        t.line(0, y, 15, y, (76, 48, 30))
    return t.im


def stairs(seed):
    t = Tile(seed)
    for k in range(4):
        c = shade((150, 150, 156), 1 - k * 0.12)
        t.rect(0, k * 4, 15, k * 4 + 3, c)
        t.line(0, k * 4 + 3, 15, k * 4 + 3, (70, 70, 76))
    t.line(0, 0, 0, 15, (60, 60, 66))
    return t.im


# ------------------------------------------------------------------ objetos (sobre el piso)

def chair(color):
    def f(seed):
        t = Tile(seed)
        dark = shade(color, 0.7)
        t.rect(4, 5, 12, 12, color)          # asiento
        t.rect(4, 2, 12, 5, dark)            # respaldo
        t.rect(10, 6, 15, 9, (34, 34, 38))   # paleta
        t.line(10, 9, 15, 9, (20, 20, 24))
        t.px(4, 13, (60, 60, 64)); t.px(12, 13, (60, 60, 64))
        t.px(4, 14, (60, 60, 64)); t.px(12, 14, (60, 60, 64))
        t.line(4, 12, 12, 12, dark)
        return t.im
    return f


def folding(seed):
    t = Tile(seed)
    t.rect(4, 3, 11, 5, (40, 40, 44))
    t.rect(4, 6, 11, 11, (60, 60, 66))
    t.line(4, 12, 4, 14, (30, 30, 34)); t.line(11, 12, 11, 14, (30, 30, 34))
    return t.im


def table_black(seed):
    t = Tile(seed)
    t.rect(0, 3, 15, 11, (36, 36, 40))
    t.line(0, 3, 15, 3, (70, 70, 76))
    t.rect(0, 12, 15, 12, (20, 20, 24))
    if seed % 2 == 0:
        t.line(1, 13, 1, 15, (20, 20, 24))
    else:
        t.line(14, 13, 14, 15, (20, 20, 24))
    return t.im


def desk_wood(seed):
    t = Tile(seed)
    t.rect(0, 3, 15, 12, (136, 92, 56))
    t.line(0, 3, 15, 3, (170, 120, 76))
    t.rect(0, 13, 15, 14, (96, 62, 38))
    if seed % 3 == 0:
        t.rect(4, 5, 9, 8, (236, 232, 220))
    return t.im


def plant(seed):
    t = Tile(seed)
    t.rect(4, 9, 11, 15, (170, 90, 60))
    t.line(4, 9, 11, 9, (200, 110, 76))
    for (x, y) in [(5, 6), (8, 4), (10, 6), (6, 8), (9, 8), (3, 7), (12, 7)]:
        t.rect(x, y, x + 1, y + 2, (60, 130, 70))
    return t.im


def plant_over(seed):
    t = Tile(seed)
    for (x, y) in [(6, 8), (8, 5), (10, 9), (4, 11), (12, 11), (7, 12), (9, 13), (5, 14), (11, 14)]:
        t.rect(x, y, x + 2, y + 2, (70, 150, 80))
        t.px(x, y, (110, 190, 110))
    return t.im


def bin_blue(seed):
    t = Tile(seed)
    t.rect(4, 4, 11, 15, (40, 90, 170))
    t.rect(4, 4, 11, 5, (70, 120, 200))
    t.rect(5, 6, 10, 6, (20, 50, 110))
    return t.im


def boxes(seed):
    t = Tile(seed)
    t.rect(1, 5, 9, 15, (166, 128, 82))
    t.line(1, 9, 9, 9, (130, 98, 60))
    t.rect(7, 1, 14, 9, (182, 142, 92))
    t.line(10, 1, 10, 9, (140, 106, 66))
    return t.im


def backpack(seed):
    t = Tile(seed)
    t.rect(4, 5, 11, 14, (150, 30, 40))
    t.rect(5, 9, 10, 12, (120, 22, 32))
    t.px(7, 4, (60, 10, 20)); t.px(8, 4, (60, 10, 20))
    return t.im


def railing(seed):
    t = Tile(seed)
    t.rect(0, 0, 15, 15, (112, 114, 120))
    t.rect(0, 2, 15, 3, (170, 172, 180))
    t.rect(0, 9, 15, 9, (150, 152, 160))
    for x in (1, 6, 11):
        t.rect(x, 2, x + 1, 15, (150, 152, 160))
    return t.im


def ac_unit(seed):
    t = Tile(seed)
    t.rect(1, 2, 14, 14, (170, 172, 176))
    t.rect(3, 4, 12, 12, (120, 122, 128))
    for y in range(5, 12, 2):
        t.line(3, y, 12, y, (90, 92, 98))
    return t.im




# ------------------------------------------------------------------ decoraciones (no bloquean)

def decal(bg, kind, x, y, seed=0):
    d = ImageDraw.Draw(bg)
    r = random.Random(seed + x * 31 + y * 17)
    X, Y = x * T, y * T
    if kind == 'paper':
        for _ in range(2):
            px_, py_ = X + r.randrange(1, 9), Y + r.randrange(2, 10)
            d.rectangle([px_, py_, px_ + 5, py_ + 4], fill=(236, 234, 226))
            d.line([px_ + 1, py_ + 1, px_ + 4, py_ + 1], fill=(150, 150, 170))
    elif kind == 'puddle':
        d.ellipse([X - 4, Y + 4, X + 20, Y + 13], fill=(70, 80, 110, 150))
        d.line([X + 2, Y + 7, X + 8, Y + 7], fill=(150, 170, 210))
    elif kind == 'stain':
        d.ellipse([X + 2, Y + 4, X + 13, Y + 12], fill=(90, 70, 60, 70))
    elif kind == 'poster':
        c = [(200, 70, 70), (70, 120, 190), (220, 180, 60), (90, 160, 100)][seed % 4]
        d.rectangle([X + 3, Y + 5, X + 12, Y + 15], fill=(240, 238, 230))
        d.rectangle([X + 4, Y + 6, X + 11, Y + 10], fill=c)
        d.line([X + 4, Y + 12, X + 10, Y + 12], fill=(90, 90, 90))
        d.line([X + 4, Y + 14, X + 8, Y + 14], fill=(90, 90, 90))
    elif kind == 'clock':
        d.ellipse([X + 3, Y + 5, X + 12, Y + 14], fill=(240, 240, 236), outline=(40, 40, 44))
        d.line([X + 8, Y + 9, X + 8, Y + 6], fill=(30, 30, 30))
        d.line([X + 8, Y + 9, X + 10, Y + 10], fill=(180, 30, 30))
    elif kind == 'extinguisher':
        d.rectangle([X + 6, Y + 3, X + 10, Y + 11], fill=(200, 30, 30))
        d.rectangle([X + 6, Y + 3, X + 10, Y + 4], fill=(40, 40, 40))
        d.rectangle([X + 3, Y + 1, X + 13, Y + 2], fill=(220, 220, 200))
    elif kind == 'leaves':
        for _ in range(5):
            lx, ly = X + r.randrange(0, 14), Y + r.randrange(0, 14)
            d.rectangle([lx, ly, lx + 1, ly + 1], fill=(120, 100, 40))
    elif kind == 'cable':
        d.line([X, Y + 8, X + 6, Y + 10, X + 15, Y + 7], fill=(30, 30, 34), width=1)
    elif kind == 'pipe':
        d.rectangle([X, Y + 5, X + 15, Y + 9], fill=(150, 150, 156))
        d.line([X, Y + 5, X + 15, Y + 5], fill=(190, 190, 196))
        d.line([X, Y + 9, X + 15, Y + 9], fill=(90, 90, 96))
    elif kind == 'sign':
        d.rectangle([X + 1, Y + 6, X + 14, Y + 11], fill=(30, 130, 60))
        d.rectangle([X + 3, Y + 8, X + 6, Y + 9], fill=(240, 240, 240))
    elif kind == 'notice':
        d.rectangle([X + 1, Y + 4, X + 14, Y + 15], fill=(150, 110, 70))
        for k in range(3):
            d.rectangle([X + 2 + k * 4, Y + 5 + (k % 2) * 3, X + 5 + k * 4, Y + 10 + (k % 2) * 3], fill=(236, 232, 220))
            d.point((X + 3 + k * 4, Y + 5 + (k % 2) * 3), fill=(200, 40, 40))


TILES = {
    '.': floor_ceramic, ',': floor_wood, ':': floor_carpet, ';': floor_concrete,
    '#': void, 'W': wall_upper, 'w': wall_lower, 'G': window_upper, 'g': window_lower,
    'B': board_upper, 'b': board_lower, 'D': door_upper, 'd': door_lower,
    'v': door_bottom, '<': door_side, '>': door_side,
    'L': locker_upper, 'l': locker_lower, 'Q': locker_ari_upper, 'q': locker_ari_lower,
    'K': shelf_upper, 'k': shelf_lower, 'S': metal_upper, 's': metal_lower,
    'F': file_upper, 'f': file_lower, 'Y': banner_upper, 'y': banner_lower,
    'E': stage, 'U': stairs,
    'h': chair((60, 160, 80)), 'p': chair((230, 90, 140)), 'n': chair((48, 48, 54)),
    'c': folding, 'T': table_black, 'O': desk_wood, 'P': plant, 't': bin_blue,
    'X': boxes, 'm': backpack, 'R': railing, 'A': ac_unit,
}
OBJECTS = set('hpncTOPtXmA')   # se dibujan sobre piso
BLOCK_FREE = set(FLOORS)


# ------------------------------------------------------------------ mapas

class Map:
    def __init__(self, mid, w, h, floor, title):
        self.id, self.w, self.h, self.floor, self.title = mid, w, h, floor, title
        self.g = [[floor] * w for _ in range(h)]
        for x in range(w):
            self.g[0][x] = '#'
            self.g[1][x] = 'W'
            self.g[2][x] = 'w'
            self.g[h - 1][x] = '#'
        for y in range(h):
            self.g[y][0] = '#'
            self.g[y][w - 1] = '#'
        self.doors = []
        self.hotspots = []
        self.lights = []
        self.spawns = {}
        self.floor_under = {}
        self.decals = []

    def put(self, x, y, ch):
        self.g[y][x] = ch

    def wall_feature(self, x0, x1, up, low):
        for x in range(x0, x1 + 1):
            self.g[1][x] = up
            self.g[2][x] = low

    def door_top(self, x, target, spawn, label):
        self.g[1][x] = 'D'
        self.g[2][x] = 'd'
        self.doors.append(dict(x=x, y=2, target=target, spawn=spawn, label=label, dir='up'))

    def door_bottom(self, x, target, spawn, label):
        self.g[self.h - 1][x] = 'v'
        self.doors.append(dict(x=x, y=self.h - 1, target=target, spawn=spawn, label=label, dir='down'))

    def door_side(self, y, side, target, spawn, label):
        x = 0 if side == 'left' else self.w - 1
        self.g[y][x] = '<' if side == 'left' else '>'
        self.doors.append(dict(x=x, y=y, target=target, spawn=spawn, label=label, dir=side))

    def hs(self, hid, x, y, label):
        self.hotspots.append(dict(id=hid, x=x, y=y, label=label))

    def render(self, panorama=None):
        bg = Image.new('RGBA', (self.w * T, self.h * T), (0, 0, 0, 255))
        over = Image.new('RGBA', (self.w * T, self.h * T), (0, 0, 0, 0))
        rnd = random.Random(hash(self.id) & 0xffff)
        for y in range(self.h):
            for x in range(self.w):
                ch = self.g[y][x]
                seed = rnd.randrange(1000)
                if ch == '~':
                    continue
                if ch in OBJECTS:
                    bg.alpha_composite(TILES[self.floor_under.get((x, y), self.floor)](seed), (x * T, y * T))
                bg.alpha_composite(TILES[ch](seed), (x * T, y * T))
                if ch == 'P' and y > 0:
                    over.alpha_composite(plant_over(seed), (x * T, (y - 1) * T))
        if panorama:
            panorama(bg, self)
        layer = Image.new('RGBA', bg.size, (0, 0, 0, 0))
        for (kind, x, y) in self.decals:
            decal(layer, kind, x, y, len(kind) + x)
        bg.alpha_composite(layer)
        self._banner(bg)
        # sombra suave bajo las paredes
        sh = Image.new('RGBA', bg.size, (0, 0, 0, 0))
        sd = ImageDraw.Draw(sh)
        for y in range(self.h):
            for x in range(self.w):
                if self.g[y][x] in BLOCK_FREE and y > 0 and self.g[y - 1][x] not in BLOCK_FREE and self.g[y - 1][x] not in OBJECTS:
                    sd.rectangle([x * T, y * T, x * T + 15, y * T + 3], fill=(0, 0, 0, 50))
        bg.alpha_composite(sh)
        bg.save(ROOT + self.id + '.png')
        over.save(ROOT + self.id + '_over.png')

    def _banner(self, bg):
        xs = [x for x in range(self.w) if self.g[1][x] == 'Y']
        if not xs:
            return
        d = ImageDraw.Draw(bg)
        x0, x1 = xs[0] * T, (xs[-1] + 1) * T
        txt = 'BIENVENIDOS'
        # fuente pixel 3x5 hecha a mano
        FONT = {
            'B': ['110', '101', '110', '101', '110'], 'I': ['111', '010', '010', '010', '111'],
            'E': ['111', '100', '110', '100', '111'], 'N': ['101', '111', '111', '111', '101'],
            'V': ['101', '101', '101', '101', '010'], 'D': ['110', '101', '101', '101', '110'],
            'O': ['111', '101', '101', '101', '111'], 'S': ['111', '100', '111', '001', '111'],
        }
        s = 2
        tw = len(txt) * 4 * s
        sx = (x0 + x1 - tw) // 2
        sy = 1 * T + 7
        for i, ch in enumerate(txt):
            for ry, row in enumerate(FONT[ch]):
                for rx, b in enumerate(row):
                    if b == '1':
                        d.rectangle([sx + i * 4 * s + rx * s, sy + ry * s, sx + i * 4 * s + rx * s + s - 1, sy + ry * s + s - 1], fill=(240, 245, 240))
        # subtítulo
        sub = 'U.T. VALLE NIEBLA'
        d.text(((x0 + x1) // 2 - len(sub) * 2, 2 * T + 1), '', fill=(255, 255, 255))

    def collision(self):
        rows = []
        for y in range(self.h):
            rows.append(''.join('0' if self.g[y][x] in BLOCK_FREE else '1' for x in range(self.w)))
        return rows

    def data(self):
        return dict(id=self.id, w=self.w, h=self.h, title=self.title, collision=self.collision(),
                    doors=self.doors, hotspots=self.hotspots, lights=self.lights, spawns=self.spawns)


def build_maps():
    maps = []

    # AUDITORIO (entrada) --------------------------------------------------
    m = Map('auditorio', 24, 14, ',', 'Auditorio')
    m.wall_feature(6, 17, 'Y', 'y')
    for x in range(5, 19):
        m.put(x, 3, 'E')
        m.put(x, 4, 'E')
    for y in (6, 8, 10):
        for x in (3, 5, 7, 9, 13, 15, 17, 19):
            if not (y == 10 and x in (7, 9, 13)):
                m.put(x, y, 'c')
    m.put(1, 12, 'P'); m.put(22, 12, 'P'); m.put(1, 3, 'P'); m.put(22, 3, 'P')
    m.door_bottom(11, 'salida', None, 'Salida')
    m.door_bottom(12, 'salida', None, 'Salida')
    m.door_side(7, 'right', 'pasillo', [1, 5], 'Pasillo')
    m.hs('escenario', 11, 4, 'Escenario')
    m.lights = [[6, 6], [12, 6], [18, 6], [8, 11], [16, 11]]
    m.decals = [('paper', 4, 9), ('paper', 14, 11), ('stain', 10, 7), ('leaves', 11, 12), ('leaves', 12, 12), ('puddle', 11, 11), ('sign', 21, 1), ('extinguisher', 2, 2)]
    m.spawns = {'start': [11, 12], 'from_pasillo': [22, 7]}
    maps.append(m)

    # PASILLO --------------------------------------------------------------
    m = Map('pasillo', 44, 10, '.', 'Pasillo — Edificio B')
    m.door_side(5, 'left', 'auditorio', [22, 7], 'Auditorio')
    m.door_top(5, 'aula', [2, 11], 'Aula B-204')
    m.door_top(12, 'biblioteca', [2, 11], 'Biblioteca')
    m.wall_feature(16, 25, 'L', 'l')
    m.put(21, 1, 'Q'); m.put(21, 2, 'q')
    m.door_top(30, 'direccion', [2, 9], 'Dirección')
    m.wall_feature(34, 38, 'G', 'g')
    m.g[1][41] = 'U'; m.g[2][41] = 'U'
    m.doors.append(dict(x=41, y=2, target='azotea', spawn=[3, 12], label='Escaleras — Azotea', dir='up'))
    m.door_bottom(22, 'bodega', [2, 9], 'Mantenimiento')
    for (x, y, c) in [(2, 3, 'P'), (9, 3, 't'), (27, 3, 'P'), (40, 3, 't'), (42, 3, 'P'),
                      (3, 8, 'h'), (8, 8, 'h'), (15, 8, 'h'), (28, 8, 'h'), (35, 8, 'h'), (36, 8, 'h')]:
        m.put(x, y, c)
    m.hs('casillero', 21, 2, 'Casillero de Ari')
    m.hs('ventanal', 36, 2, 'Ventanal')
    m.lights = [[4, 5], [11, 5], [18, 5], [25, 5], [32, 5], [39, 5]]
    m.decals = [('poster', 3, 1), ('poster', 8, 1), ('notice', 14, 1), ('clock', 27, 1), ('poster', 32, 1), ('extinguisher', 10, 2), ('extinguisher', 39, 2), ('sign', 43, 4),
                ('puddle', 36, 3), ('puddle', 37, 4), ('paper', 19, 6), ('paper', 6, 7), ('stain', 25, 6), ('leaves', 41, 3), ('paper', 33, 5)]
    m.spawns = {'from_auditorio': [1, 5], 'from_aula': [5, 3], 'from_biblioteca': [12, 3],
                'from_direccion': [30, 3], 'from_azotea': [41, 3], 'from_bodega': [22, 8]}
    maps.append(m)

    # AULA B-204 -----------------------------------------------------------
    m = Map('aula', 20, 13, '.', 'Aula B-204')
    m.wall_feature(2, 10, 'B', 'b')
    m.wall_feature(13, 18, 'G', 'g')
    m.put(12, 1, 'W'); m.put(12, 2, 'w')
    m.door_bottom(2, 'pasillo', [5, 3], 'Pasillo')
    for x in (3, 4, 5):
        m.put(x, 4, 'T')
    cols = 'hpnhphn'
    for ri, y in enumerate((6, 8, 10)):
        for ci, x in enumerate((5, 7, 9, 11, 13, 15, 17)):
            m.put(x, y, cols[(ci + ri) % len(cols)])
    m.put(9, 3, 't')
    m.put(11, 8, 'p')        # pupitre de Ari
    m.put(12, 9, 'm')        # mochila
    m.put(18, 4, 'O')        # estante/mesa del fondo
    m.put(18, 5, 'O')
    m.hs('pizarron', 6, 2, 'Pizarrón')
    m.hs('pupitre', 11, 8, 'Pupitre de Ari')
    m.hs('mochila', 12, 9, 'Mochila')
    m.hs('tablon', 12, 2, 'Tablón de avisos')
    m.hs('estante', 18, 4, 'Mesa del fondo')
    m.lights = [[5, 6], [11, 6], [16, 6], [8, 10], [15, 10]]
    m.decals = [('clock', 11, 1), ('notice', 12, 1), ('paper', 8, 7), ('paper', 14, 9), ('paper', 16, 11), ('puddle', 15, 3), ('cable', 3, 5), ('stain', 9, 11)]
    m.spawns = {'from_pasillo': [2, 11]}
    maps.append(m)

    # BIBLIOTECA -----------------------------------------------------------
    m = Map('biblioteca', 22, 13, ',', 'Biblioteca')
    m.wall_feature(1, 20, 'K', 'k')
    m.wall_feature(4, 6, 'G', 'g')
    m.door_bottom(2, 'pasillo', [12, 3], 'Pasillo')
    for x in (4, 5, 6, 7):
        m.put(x, 6, 'O')
    for x in (15, 16, 17, 18):
        m.put(x, 9, 'O')
    for x in (9, 10, 11, 12):
        m.put(x, 5, 'K'); m.put(x, 6, 'k')
        m.put(x, 8, 'K'); m.put(x, 9, 'k')
    m.put(20, 11, 'P'); m.put(1, 4, 'P')
    m.hs('mesa_dibujo', 5, 6, 'Mesa junto a la ventana')
    m.hs('estanteria', 16, 2, 'Estantería de arquitectura')
    m.hs('mesa_fondo', 17, 9, 'Mesa del fondo')
    m.lights = [[5, 4], [16, 5], [10, 11], [17, 11]]
    m.decals = [('paper', 8, 7), ('paper', 13, 4), ('paper', 3, 10), ('stain', 14, 7), ('puddle', 5, 3)]
    m.spawns = {'from_pasillo': [2, 11]}
    maps.append(m)

    # BODEGA DE MANTENIMIENTO --------------------------------------------
    m = Map('bodega', 16, 11, ';', 'Bodega de mantenimiento')
    m.wall_feature(1, 14, 'S', 's')
    m.door_bottom(2, 'pasillo', [22, 8], 'Pasillo')
    for (x, y) in [(5, 5), (6, 5), (10, 6), (11, 6), (12, 4), (13, 8), (4, 8), (8, 8)]:
        m.put(x, y, 'X')
    m.hs('herramientas', 6, 2, 'Herramientas')
    m.hs('cajas', 11, 6, 'Cajas viejas')
    m.lights = [[8, 5]]
    m.decals = [('stain', 7, 7), ('stain', 3, 5), ('cable', 9, 4), ('cable', 10, 4), ('paper', 13, 9), ('puddle', 7, 9)]
    m.spawns = {'from_pasillo': [2, 9]}
    maps.append(m)

    # DIRECCIÓN ------------------------------------------------------------
    m = Map('direccion', 16, 11, ':', 'Dirección de carrera')
    m.wall_feature(5, 8, 'G', 'g')
    m.wall_feature(11, 13, 'F', 'f')
    m.door_bottom(2, 'pasillo', [30, 3], 'Pasillo')
    for x in (5, 6, 7, 8):
        m.put(x, 5, 'O')
    m.put(6, 6, 'n')
    m.put(1, 3, 'P'); m.put(14, 9, 'P')
    m.hs('escritorio', 6, 5, 'Escritorio')
    m.hs('archivero', 12, 2, 'Archivero')
    m.lights = [[6, 5], [12, 6]]
    m.decals = [('clock', 3, 1), ('poster', 9, 1), ('paper', 9, 7), ('paper', 4, 8)]
    m.spawns = {'from_pasillo': [2, 9]}
    maps.append(m)

    # AZOTEA ---------------------------------------------------------------
    m = Map('azotea', 26, 14, ';', 'Azotea')
    for y in range(0, 4):
        for x in range(26):
            m.g[y][x] = '~'
    for x in range(26):
        m.g[4][x] = 'R'
    for y in range(4, 14):
        m.g[y][0] = 'R' if y > 4 else 'R'
        m.g[y][25] = 'R'
    for x in range(26):
        m.g[13][x] = '#'
    m.door_bottom(3, 'pasillo', [41, 3], 'Escaleras')
    for (x, y) in [(20, 7), (21, 7), (20, 10), (6, 10)]:
        m.put(x, y, 'A')
    m.hs('baranda', 13, 4, 'La baranda')
    m.lights = []
    m.decals = [('puddle', 5, 6), ('puddle', 15, 9), ('puddle', 9, 11), ('puddle', 22, 5)] + [('pipe', x, 12) for x in range(6, 18)] + [('leaves', 12, 7), ('leaves', 17, 11)]
    m.spawns = {'from_pasillo': [3, 12]}

    def panorama(bg, mm):
        d = ImageDraw.Draw(bg)
        W = mm.w * T
        H = 4 * T + 8
        for y in range(H):
            k = y / H
            c = (int(14 + 30 * k), int(16 + 22 * k), int(36 + 30 * k))
            d.line([(0, y), (W, y)], fill=c)
        r = random.Random(7)
        for _ in range(60):
            d.point((r.randrange(W), r.randrange(0, 30)), fill=(200, 200, 230))
        # bosque (como las fotos de la cancha)
        for x in range(0, W, 3):
            hgt = 10 + int(6 * abs(np.sin(x * 0.21))) + r.randrange(0, 5)
            d.rectangle([x, H - 22 - hgt, x + 3, H - 18], fill=(14, 30, 24))
        # cancha
        d.rectangle([0, H - 18, W, H], fill=(30, 52, 34))
        d.line([(40, H - 12), (W - 40, H - 12)], fill=(70, 96, 72))
        for gx in (60, W - 66):
            d.rectangle([gx, H - 16, gx + 6, H - 12], outline=(160, 170, 160))
        # luces lejanas
        for _ in range(26):
            x = r.randrange(W)
            d.point((x, H - 24 - r.randrange(0, 6)), fill=(240, 200, 120))
    m.render_panorama = panorama
    maps.append(m)
    return maps


if __name__ == '__main__':
    out = {}
    for m in build_maps():
        for y, row in enumerate(m.g):
            assert len(row) == m.w, (m.id, y)
        m.render(getattr(m, 'render_panorama', None))
        out[m.id] = m.data()
    with open(ROOT + 'maps.json', 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
    # vista previa
    ims = [Image.open(ROOT + k + '.png') for k in out]
    W = max(i.width for i in ims)
    H = sum(i.height + 8 for i in ims)
    prev = Image.new('RGBA', (W, H), (40, 40, 40, 255))
    y = 0
    for i in ims:
        prev.alpha_composite(i, (0, y))
        y += i.height + 8
    prev.resize((W * 2, H * 2), Image.NEAREST).save(os.path.join(HERE, 'preview_maps_preview.png'))
    print('ok', list(out))
