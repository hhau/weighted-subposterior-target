library(rstan)

sim_pars <- readRDS("rds/norm-norm-ex/sim-pars.rds")
stage_one_data <- readRDS("rds/norm-norm-ex/data-model-one.rds")
u_func_args <- readRDS("rds/norm-norm-ex/with-u/u-func-args.rds")
prefit <- stan_model("scripts/norm-norm-ex/stan-files/augmented-stage-one-target.stan")

stan_data <- list(
  n_y = length(stage_one_data$y),
  y = stage_one_data$y,
  sd_y = sim_pars$sigma_1,
  y_1_mean = u_func_args$y_1_mean,
  y_1_sd = u_func_args$y_1_sd,
  y_2_mean = u_func_args$y_2_mean,
  y_2_sd = u_func_args$y_2_sd,
  k = 3
)

model_fit <- sampling(
  prefit,
  data = stan_data
)

phi_samples <- as.vector(as.array(model_fit, pars = "phi"))

saveRDS(
  file = "rds/norm-norm-ex/with-u/phi-samples-stage-one.rds",
  object = phi_samples
)
