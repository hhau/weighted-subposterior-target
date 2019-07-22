stage_one_data <- readRDS("rds/norm-norm-ex/data-model-one.rds")
stage_two_data <- readRDS("rds/norm-norm-ex/data-model-two.rds")

N <- length(stage_one_data$y)
k <- 3
mu_y_1 <- mean(stage_one_data$y)
var_y_1 <- var(stage_one_data$y)
mu_y_2 <- mean(stage_two_data$y)
var_y_2 <- var(stage_two_data$y)

mu_u <- (var_y_1 * mu_y_2 + var_y_2 * mu_y_1) / (var_y_1 + var_y_2)
var_u <- (var_y_1 * var_y_2) / (var_y_1 + var_y_2)

u_func_args <- list(
  k = k,
  y_1_mean = mean(stage_one_data$y),
  y_2_mean = mean(stage_two_data$y),
  y_1_sd = sd(stage_one_data$y),
  y_2_sd = sd(stage_two_data$y),
  mu_u = mu_u,
  sd_u = sqrt(var_u)
)

saveRDS(
  object = u_func_args,
  file = "rds/norm-norm-ex/with-u/u-func-args.rds"
)