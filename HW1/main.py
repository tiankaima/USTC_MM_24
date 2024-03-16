import numpy as np
import matplotlib.pyplot as plt
from scipy.ndimage import convolve
from imageio import imread, imwrite
from tqdm import tqdm, trange

def calculate_energy(img):
    du_filter = np.array([
        [1.0, 2.0, 1.0],
        [0.0, 0.0, 0.0],
        [-1.0, -2.0, -1.0]
    ])
    dv_filter = np.array([
        [1.0, 0.0, -1.0],
        [2.0, 0.0, -2.0],
        [1.0, 0.0, -1.0]
    ])
    du_filter = np.stack([du_filter] * 3, axis=2)
    dv_filter = np.stack([dv_filter] * 3, axis=2)
    img = np.array(img).astype('float32')
    convolved = np.abs(convolve(img, du_filter)) + np.abs(convolve(img, dv_filter))
    energy_map = convolved.sum(axis=2)
    return energy_map

def min_seam(img):
    row, col, _ = img.shape
    energy_map = calculate_energy(img)
    M = energy_map.copy()
    backtrack = np.zeros_like(M, dtype=int)

    for i in range(1, row):
        for j in range(0, col):
            if j == 0:
                idx = np.argmin(M[i - 1, j : j + 2])
                backtrack[i, j] = idx + j
                min_energy = M[i - 1, idx + j]
            else:
                idx = np.argmin(M[i - 1, j - 1 : j + 2])
                backtrack[i, j] = idx + j - 1
                min_energy = M[i - 1, idx + j - 1]
            M[i, j] += min_energy

    return M, backtrack

def carve_col(img):
    row, col, _ = img.shape
    M, backtrack = min_seam(img)
    mask = np.ones((row, col), dtype=bool)
    j = np.argmin(M[-1])
    for i in range(row-1, -1, -1):
        mask[i, j] = False
        j = backtrack[i, j]
    mask = np.stack([mask] * 3, axis=2)
    img = img[mask].reshape((row, col-1, 3))
    return img

def crop_col(img, scale_c):
    row, col, _ = img.shape
    new_col = int(col * scale_c)
    for i in trange(col - new_col):
        img = carve_col(img)
    return img

img = imread('example.jpg')
img = crop_col(img, 0.5)
plt.imshow(img)
