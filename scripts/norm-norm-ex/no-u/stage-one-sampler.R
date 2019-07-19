library(rstan)

sim_pars <- readRDS("rds/norm-norm-ex/sim-pars.rds")
stage_one_data <- readRDS("rds/norm-norm-ex/data-model-one.rds")
prefit <- stan_model("scripts/norm-norm-ex/stan-files/stage-one-target.stan")

stan_data <- list(
  n_y = length(stage_one_data$y),
  y = stage_one_data$y,
  sd_y = sim_pars$sigma_1
)

model_fit <- sampling(prefit, data = stan_data)
phi_samples <- as.vector(as.array(model_fit, pars = "phi"))

saveRDS(
  object = phi_samples,
  file = "rds/norm-norm-ex/no-u/phi-samples-stage-one.rds"
)
