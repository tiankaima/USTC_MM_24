#!/usr/bin/env python

# input given image, svd compress it, and export to given folder
# Usage: python main.py -i <input_image> -o <output_folder> -k <k_value>
import cv2
import numpy as np
import os
import argparse
