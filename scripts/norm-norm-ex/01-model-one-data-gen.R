sim_pars <- readRDS("rds/norm-norm-ex/sim-pars.rds")

with(sim_pars, {
  generated_phi <- rnorm(n = 1, mean = mu_phi_1, sd = sigma_phi_1)
  generated_y_1 <- rnorm(n = n_y_1, mean = generated_phi, sd = sigma_1)
  saveRDS(
    file = "rds/norm-norm-ex/data-model-one.rds",
    object = list(y = generated_y_1, phi = generated_phi)
  )
})
