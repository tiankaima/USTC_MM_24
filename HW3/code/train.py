import tensorflow as tf
from tensorflow.keras.layers import Dense, Dropout, Flatten, Conv2D, MaxPooling2D
from tensorflow.keras.optimizers import Adam
from tensorflow.keras import Model
from tensorflow.keras import datasets
from tensorflow.keras import utils


# load data from ./insects.
# training: ./insects/insects-training.txt
# format as the following:
# x y category
def load_data(file_path: str):
    def decode_line(line):
        parts = tf.strings.split(line, sep=' ')
        x = tf.strings.to_number(parts[0], tf.float32)
        y = tf.strings.to_number(parts[1], tf.float32)
        category = tf.strings.to_number(parts[2], tf.int32)
        return (x, y), category

    dataset = tf.data.TextLineDataset(file_path).map(decode_line)
    return dataset


train_data = load_data("./insects/insects-training.txt")
test_data = load_data("./insects/insects-testing.txt")

x_train, y_train = train_data.take(1), train_data.take(2)
x_test, y_test = test_data.take(1), test_data.take(2)

model = tf.keras.models.Sequential([
    Dense(512, activation='relu'),
    Dropout(0.5),
    Dense(256, activation='relu'),
    Dropout(0.5),
])

print(x_train, y_train, x_test, y_test)
