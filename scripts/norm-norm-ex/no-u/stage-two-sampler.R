library(futile.logger)

stage_one_samples <- readRDS("rds/norm-norm-ex/no-u/phi-samples-stage-one.rds")
sim_pars <- readRDS("rds/norm-norm-ex/sim-pars.rds")
stage_two_data <- readRDS("rds/norm-norm-ex/data-model-two.rds")

n_samples <- length(stage_one_samples)
stage_two_samples <- array(NA, dim = n_samples)
stage_two_samples[1] <- sample(stage_one_samples, 1)

p_pool_phi <- function(phi) {
  res <- 
    0.5 * dnorm(phi, mean = sim_pars$mu_phi_1, sd = sim_pars$sigma_phi_1) +
    0.5 * dnorm(phi, mean = sim_pars$mu_phi_2, sd = sim_pars$sigma_phi_2) 
}

for (ii in 2:n_samples) {
  phi_prop <- sample(stage_one_samples, 1)
  phi_curr <- stage_two_samples[ii - 1]

  # In this example the prior marginals cancel in the factorisation
  # so we don't have to worry about them
  log_ppool_term <- log(p_pool_phi(phi_prop)) - log(p_pool_phi(phi_curr))
  log_likelihood_term <- 
    sum(dnorm(x = stage_two_data$y, mean = phi_prop, sd = sim_pars$sigma_2, log = T)) -
    sum(dnorm(x = stage_two_data$y, mean = phi_curr, sd = sim_pars$sigma_2, log = T))

  log_accept_prob <- log_ppool_term + log_likelihood_term

  if (runif(1) < exp(log_accept_prob)) {
    stage_two_samples[ii] <- phi_prop
  } else {
    stage_two_samples[ii] <- phi_curr
  }

  if (ii %% 100 == 0) {
    flog.info("iter: %d", ii)
  }

}

saveRDS(
  object = stage_two_samples,
  file = "rds/norm-norm-ex/no-u/phi-samples-stage-two.rds"
)