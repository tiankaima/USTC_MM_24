// Use svd to compress image

#include <iostream>

#define STB_IMAGE_IMPLEMENTATION

#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION

#include "stb_image_write.h"

#include "Eigen/Dense"
#include "Eigen/SVD"


int main(int argc, char **argv) {
    if (argc != 4) {
        std::cerr << "Usage: " << argv[0] << " <input_image_path> <output_image_path> <quality>" << std::endl;
        return 1;
    }

    // load image:
    int width, height, channels;
    unsigned char *img = stbi_load(argv[1], &width, &height, &channels, 0);
    if (img == nullptr) {
        std::cerr << "Error: failed to load image" << std::endl;
        return 1;
    }

    // parse quality into int
    int quality = std::stoi(argv[3]);
    std::cout << quality << std::endl;

    // load into a Matrix:
    Eigen::MatrixXd img_matrix(height, width * channels);
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width * channels; j++) {
            img_matrix(i, j) = img[i * width * channels + j];
        }
    }

    // SVD:
    Eigen::JacobiSVD<Eigen::MatrixXd> svd(img_matrix, Eigen::ComputeThinU | Eigen::ComputeThinV);

    Eigen::MatrixXd U = svd.matrixU();
    Eigen::MatrixXd V = svd.matrixV();
    Eigen::VectorXd S = svd.singularValues();

    // compress:
    int k = quality;
    Eigen::MatrixXd img_matrix_compressed = U.leftCols(k) * S.head(k).asDiagonal() * V.leftCols(k).transpose();

    // save image:
    unsigned char *img_compressed = new unsigned char[height * width * channels];
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width * channels; j++) {
            img_compressed[i * width * channels + j] = img_matrix_compressed(i, j);
        }
    }
    stbi_write_png(argv[2], width, height, channels, img_compressed, width * channels);

    // free memory:
    stbi_image_free(img);
    delete[] img_compressed;

    // print hint:
    std::cout << "File saved at " << argv[2] << "with quality: " << argv[3] << std::endl;

    return 0;
}