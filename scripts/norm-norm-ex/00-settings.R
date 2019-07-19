sim_pars <- list(
  n_y_1 = 5,
  n_y_2 = 5,
  sigma_1 = 1,
  sigma_2 = 1,
  mu_phi_1 = -2,
  mu_phi_2 = 2,
  sigma_phi_1 = 1,
  sigma_phi_2 = 1
)

saveRDS(
  file = "rds/norm-norm-ex/sim-pars.rds",
  object = sim_pars
)