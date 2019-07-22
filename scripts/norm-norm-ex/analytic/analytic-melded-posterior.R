sim_pars <- readRDS("rds/norm-norm-ex/sim-pars.rds")
data_one <- readRDS("rds/norm-norm-ex/data-model-one.rds")
data_two <- readRDS("rds/norm-norm-ex/data-model-two.rds")

### CRITICAL THAT WE WORK WITH VARIANCES HERE ###
# The analytical form of the melded posterior.
# We have:
# m = {1, 2} models
# define i, j = {1, 2} × {1, 2}, the {(1, 1), (1, 2), (2, 1), (2, 2)} pair space
# the terms are of the form:
# p_{i}(phi) p_{j}(Y_{j} | phi)
# 
## prior term
# p_{i}(phi) - is a normal density with mean mu_{i}, and variance sigma^{2}_{i}.
## Likelihood term
# Note that Y_{j} = {y_{1}, ..., y_{N_{j}}}, with n = 1, ..., N_{j}
# p_{j}(Y_{j} | phi)
# in this case, all the observations come from the same normal, so have the 
# same variance
## product of prior and likelihood term
# It is more sensible to assess all the terms at once, because the bromiley
# algebra is written for the product of $N$ distinct (unique mean/sd) normal
# density functions/
product_term <- function(y_vec, y_eps, phi_mu, phi_sigma) {
  N_y <- length(y_vec)

  # there's nothing numerically crazy here?
  product_variance <- ((N_y / (y_eps^2)) + (1 / (phi_sigma^2)))^(-1)
  product_mean <- (((1/(y_eps^2)) * sum(y_vec)) + (phi_mu / (phi_sigma^2))) * (product_variance)

  theta_vec <- c(
    (y_vec^2) / (y_eps^2),
    (phi_mu^2) / (phi_sigma^2)
  )

  # this is going to be numerically challenging
  # for now, return the log_scale_factor and we'll see if we can stabilise 
  # the calculation with LSE
  log_scale_factor <- 
    (-N_y / 2) * log(2 * pi) +
    (1 / 2) * (log(product_variance) - 2 * (N_y * log(y_eps) + log(phi_sigma))) + 
    (-1 / 2) * (sum(theta_vec - ((product_mean^2) / product_variance)))
  
  res <- list(
    mean = product_mean,
    variance = product_variance,
    log_scale_factor = log_scale_factor
  )
  
  return(res)

}

## sum of 4 prior × likelihood terms - can compute NC's for all
# term names from Appendix A of conjugate-normal-example
term_one <- product_term(
  y_vec = data_one$y,
  y_eps = sim_pars$sigma_1,
  phi_mu = sim_pars$mu_phi_1,
  phi_sigma = sim_pars$sigma_phi_1
)

term_two <- product_term(
  y_vec = data_two$y,
  y_eps = sim_pars$sigma_2,
  phi_mu = sim_pars$mu_phi_1,
  phi_sigma = sim_pars$sigma_phi_1
)

term_three <- product_term(
  y_vec = data_one$y,
  y_eps = sim_pars$sigma_1,
  phi_mu = sim_pars$mu_phi_2,
  phi_sigma = sim_pars$sigma_phi_2
)

term_four <- product_term(
  y_vec = data_two$y,
  y_eps = sim_pars$sigma_2,
  phi_mu = sim_pars$mu_phi_2,
  phi_sigma = sim_pars$sigma_phi_2
)

# !! extreme care required to deal with the log_scale_factors!!
# numerics are horrible - don't quite understand why though? 
max_log_scale_factor <- max(
  term_one$log_scale_factor,
  term_two$log_scale_factor,
  term_three$log_scale_factor,
  term_four$log_scale_factor
)

all_log_scale_factors <- c(
  term_one$log_scale_factor,
  term_two$log_scale_factor,
  term_three$log_scale_factor,
  term_four$log_scale_factor
)

scale_factor_normaliser <- max_log_scale_factor + log(sum(exp(all_log_scale_factors - max_log_scale_factor)))

term_one$normalised_weight <- exp(term_one$log_scale_factor - scale_factor_normaliser)
term_two$normalised_weight <- exp(term_two$log_scale_factor - scale_factor_normaliser)
term_three$normalised_weight <- exp(term_three$log_scale_factor - scale_factor_normaliser)
term_four$normalised_weight <- exp(term_four$log_scale_factor  - scale_factor_normaliser)

terms_list <- list(
  term_one,
  term_two,
  term_three,
  term_four
)

# only pointwise - sapply out of trouble.
analytical_posterior <- function(phi) {
  term_contributions <- lapply(terms_list, function(a_term) {
    dnorm(x = phi, mean = a_term$mean, sd = sqrt(a_term$variance)) * a_term$normalised_weight
  })
  res <- sum(unlist(term_contributions))
}

p_df <- data.frame(
  x = seq(from = -5, to = 5, length.out = 1000),
  y = sapply(p_df$x, analytical_posterior)
)

ggplot(p_df, aes(x = x, y = y)) +
  geom_point()
