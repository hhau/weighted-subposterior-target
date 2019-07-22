library(rstan)

sim_pars <- readRDS("rds/norm-norm-ex/sim-pars.rds")
stage_one_data <- readRDS("rds/norm-norm-ex/data-model-one.rds")
u_func_args <- readRDS("rds/norm-norm-ex/with-u-2/u-func-args.rds")
prefit <- stan_model("scripts/norm-norm-ex/stan-files/augmented-stage-one-target-two.stan")

stan_data <- list(
  n_y = length(stage_one_data$y),
  y = stage_one_data$y,
  sd_y = sim_pars$sigma_1,
  mu_nu = u_func_args$mu_nu,
  sd_nu = sqrt(u_func_args$var_nu),
  mu_de = u_func_args$mu_de,
  sd_de  = sqrt(u_func_args$var_de)
)

model_fit <- sampling(
  prefit,
  data = stan_data
)

phi_samples <- as.vector(as.array(model_fit, pars = "phi"))

saveRDS(
  file = "rds/norm-norm-ex/with-u-2/phi-samples-stage-one.rds",
  object = phi_samples
)