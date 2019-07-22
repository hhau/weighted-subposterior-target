library(rstan)

sim_pars <- readRDS("rds/norm-norm-ex/sim-pars.rds")
stage_two_data <- readRDS("rds/norm-norm-ex/data-model-two.rds")
# note that we use the same Stan model
prefit <- stan_model("scripts/norm-norm-ex/stan-files/stage-one-target.stan")

# sample the first model

stan_data <- list(
  n_y = length(stage_two_data$y),
  y = stage_two_data$y,
  sd_y = sim_pars$sigma_2
)

model_fit <- sampling(
  prefit,
  data = stan_data
)

phi_samples <- as.vector(as.array(model_fit, pars = "phi"))

saveRDS(
  object = phi_samples,
  file = "rds/norm-norm-ex/with-u-2/phi-samples-model-two.rds"
)
