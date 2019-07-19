stage_one_data <- readRDS("rds/norm-norm-ex/data-model-one.rds")
stage_two_data <- readRDS("rds/norm-norm-ex/data-model-two.rds")

u_func_args <- list(
  k = 3,
  y_1_mean = mean(stage_one_data$y),
  y_2_mean = mean(stage_two_data$y),
  y_1_sd = sd(stage_one_data$y),
  y_2_sd = sd(stage_two_data$y)
)

saveRDS(
  object = u_func_args,
  file = "rds/norm-norm-ex/with-u/u-func-args.rds"
)