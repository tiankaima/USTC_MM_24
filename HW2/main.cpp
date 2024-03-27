// Use svd to compress image

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <vector>

#include "stb_image.h"
#include "stb_image_write.h"



int main(int argc, char** argv)
{
    if (argc != 4) {
        std::cerr << "Usage: " << argv[0] << " <input_image_path> <output_image_path> <quality>" << std::endl;
        return 1;
    }

    int width, height, channels;
    unsigned char* img = stbi_load(argv[1], &width, &height, &channels, 0);
    if (img == NULL) {
        std::cerr << "Error: failed to load image" << std::endl;
        return 1;
    }
}