library(rstan)

sim_pars <- readRDS("rds/norm-norm-ex/sim-pars.rds")
data_one <- readRDS("rds/norm-norm-ex/data-model-one.rds")
data_two <- readRDS("rds/norm-norm-ex/data-model-two.rds")

prefit <- stan_model("scripts/norm-norm-ex/stan-files/melded-posterior.stan")

with(sim_pars,  {
  stan_data <<- list(
    n_y_1 = n_y_1,
    n_y_2 = n_y_2,
    y_1 = data_one$y,
    y_2 = data_two$y,
    sigma_1 = sigma_1,
    sigma_2 = sigma_2,
    mu_phi_1 = mu_phi_1,
    mu_phi_2 = mu_phi_2,
    sigma_phi_1 = sigma_phi_1,
    sigma_phi_2 = sigma_phi_2
  )  
})

model_fit <- sampling(
  prefit,
  data = stan_data
)

phi_samples <- as.vector(as.array(model_fit, pars = "phi"))

saveRDS(
  file = "rds/norm-norm-ex/joint/phi-samples-joint.rds",
  object = phi_samples
)