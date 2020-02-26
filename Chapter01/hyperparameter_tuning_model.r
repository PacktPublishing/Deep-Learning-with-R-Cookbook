
library(keras)
library(datasets)

mnist <- dataset_mnist()
x_train <- mnist$train$x
y_train <- mnist$train$y
x_test <- mnist$test$x
y_test <- mnist$test$y

# reshape
x_train <- array_reshape(x_train, c(nrow(x_train), 784))
x_test <- array_reshape(x_test, c(nrow(x_test), 784))
# rescale
x_train <- x_train / 255
x_test <- x_test / 255

y_train <- to_categorical(y_train, 10)
y_test <- to_categorical(y_test, 10)

FLAGS <- flags(
    flag_integer("dense_units1",8),
    flag_numeric("dropout1",0.4),
    flag_integer("dense_units2",8),
    flag_numeric("dropout2", 0.3)
)

model <- keras_model_sequential()
model %>%
  layer_dense(units = FLAGS$dense_units1, activation = 'relu', input_shape = c(784)) %>%
  layer_dropout(rate = FLAGS$dropout1) %>%
  layer_dense(units = FLAGS$dense_units2, activation = 'relu') %>%
  layer_dropout(rate = FLAGS$dropout2) %>%
  layer_dense(units = 10, activation = 'softmax')

model %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = optimizer_rmsprop(lr = 0.001),
  metrics = c('accuracy')
)

# Training & Evaluation ----------------------------------------------------

history <- model %>% fit(
  x_train, y_train,
  batch_size = 128,
  epochs = 20,
  verbose = 1,
  validation_split = 0.2
)

plot(history)

score <- model %>% evaluate(
  x_test, y_test,
  verbose = 0
)

cat('Test loss:', score$loss, '\n')
cat('Test accuracy:', score$acc, '\n')