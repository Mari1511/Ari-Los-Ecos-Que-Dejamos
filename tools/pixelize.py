import os
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
import sys
import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

def pixelize(src, out, colors=28, target_h=196):
    im = Image.open(src).convert('RGB')
    s = target_h / im.height
    im = im.resize((round(im.width * s), target_h), Image.LANCZOS)
    a = np.array(im).astype(int)
    # fondo blanco -> transparente (flood desde bordes)
    near = (a.min(-1) > 232)
    lab, n = ndimage.label(near)
    border = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    bg = np.isin(lab, list(border))
    fg = ~bg
    fg = ndimage.binary_opening(fg, iterations=1)
    lab2, n2 = ndimage.label(fg)
    if n2 > 1:
        sizes = ndimage.sum(fg, lab2, range(1, n2 + 1))
        fg = lab2 == (np.argmax(sizes) + 1)
    fg = ndimage.binary_fill_holes(fg)
    # cuantizar paleta
    q = Image.fromarray(a.astype(np.uint8)).quantize(colors=colors, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert('RGB')
    qa = np.array(q).astype(int)
    # contorno oscuro de 1 px
    edge = fg & ~ndimage.binary_erosion(fg)
    outline = np.array([28, 16, 24])
    qa[edge] = (qa[edge] * 0.25 + outline * 0.75).astype(int)
    rgba = np.dstack([qa, fg * 255]).astype(np.uint8)
    Image.fromarray(rgba, 'RGBA').save(out)

if __name__ == '__main__':
    pixelize(sys.argv[1], sys.argv[2])
