sim_pars <- readRDS("rds/norm-norm-ex/sim-pars.rds")

with(sim_pars, {
  generated_phi <- rnorm(n = 1, mean = mu_phi_2, sd = sigma_phi_2)
  generated_y_2 <- rnorm(n = n_y_2, mean = generated_phi, sd = sigma_2)
  saveRDS(
    file = "rds/norm-norm-ex/data-model-two.rds",
    object = list(y = generated_y_2, phi = generated_phi)
  )
})
