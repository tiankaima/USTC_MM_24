#!/usr/bin/env python

# input given image, svd compress it, and export to given folder
# Usage: python main.py -i <input_image> -o <output_folder> -k <k_value>
import cv2
import numpy as np
import os
import argparse
import matplotlib.pyplot as plt


def svd_compress(image_path: str, output_folder: str, k: int, color: bool, export_sigma_distribution: bool):
    if not color:
        img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
        U, S, Vt = np.linalg.svd(img, full_matrices=False)

        if export_sigma_distribution:
            plt.plot(S)
            plt.xlabel("Singular Value Index")
            plt.ylabel("Singular Value")
            plt.title("Singular Value Distribution")
            filename = os.path.basename(image_path).split(".")[0]
            plt.savefig(os.path.join(output_folder, f"{filename}-sigma_distribution.png"))
            plt.close()

        compressed_img = np.dot(U[:, :k], np.dot(np.diag(S[:k]), Vt[:k, :]))
    else:
        img = cv2.imread(image_path, cv2.IMREAD_COLOR)
        img_b, img_g, img_r = cv2.split(img)
        compressed_imgs = []
        for img in [img_b, img_g, img_r]:
            U, S, Vt = np.linalg.svd(img, full_matrices=False)
            compressed_img = np.dot(U[:, :k], np.dot(np.diag(S[:k]), Vt[:k, :]))
            compressed_imgs.append(compressed_img)

        compressed_img = cv2.merge(compressed_imgs)

    # create output folder if not exists
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # export to _output_/_filename_-{k}.jpg:
    filename = os.path.basename(image_path).split(".")[0]
    output_path = os.path.join(output_folder, f"{filename}-{k}.jpg")
    cv2.imwrite(output_path, compressed_img)


def main():
    parser = argparse.ArgumentParser(description="SVD Image Compression")
    parser.add_argument(
        "-i",
        "--input",
        type=str,
        required=True,
        help="input image path",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=str,
        required=True,
        help="output folder path",
    )
    parser.add_argument(
        "-k",
        "--k_value",
        type=int,
        required=True,
        help="k value for compression",
    )
    parser.add_argument(
        "-c",
        "--color",
        type=bool,
        default=False,
        help="color image or grayscale image",
    )
    parser.add_argument(
        "-e",
        "--export-sigma-distribution",
        type=bool,
        default=False,
        help="export sigma distribution",
    )
    args = parser.parse_args()
    svd_compress(args.input, args.output, args.k_value, args.color, args.export_sigma_distribution)


if __name__ == "__main__":
    main()
