library(tibble)
library(forcats)
source("scripts/common/plot-settings.R")

sim_pars <- readRDS("rds/norm-norm-ex/sim-pars.rds")
stage_one_data <- readRDS("rds/norm-norm-ex/data-model-one.rds")
stage_two_data <- readRDS("rds/norm-norm-ex/data-model-two.rds")

# first the model one subposterior
subposterior_one <- function(phi, log_scale = FALSE) {
  log_res <- sapply(phi, function(a_phi) {
    sum(dnorm(
      x = stage_one_data$y,
      mean = a_phi,
      sd = sim_pars$sigma_1,
      log = TRUE
    )) +
      dnorm(
        x = a_phi,
        mean = sim_pars$mu_phi_1,
        sd = sim_pars$sigma_phi_1,
        log = TRUE
      )
  })

  if (log_scale) {
    return(log_res)
  } else {
    return(exp(log_res))
  }

}

nc_subpost_one <- integrate(
  subposterior_one,
  lower = -10,
  upper = 10
)

# then the stage one target distribution
stage_one_target <- function(phi, log_scale = FALSE) {
  log_res <- sapply(phi, function(a_phi) {
    sum(dnorm(
      x = stage_one_data$y,
      mean = a_phi,
      sd = sim_pars$sigma_1,
      log = TRUE
    ))
  })

  if (log_scale) {
    return(log_res)
  } else {
    return(exp(log_res))
  }

}

nc_target_one <- integrate(
  stage_one_target,
  lower = -10,
  upper = 10
)

# the the second subposterior
subposterior_two <- function(phi, log_scale = FALSE) {
  log_res <- sapply(phi, function(a_phi) {
    sum(dnorm(
      x = stage_two_data$y,
      mean = a_phi,
      sd = sim_pars$sigma_2,
      log = TRUE
    )) +
      dnorm(
        x = a_phi,
        mean = sim_pars$mu_phi_2,
        sd = sim_pars$sigma_phi_2,
        log = TRUE
      )
  })

  if (log_scale) {
    return(log_res)
  } else {
    return(exp(log_res))
  }

}

nc_subpost_two <- integrate(
  subposterior_two,
  lower = -10,
  upper = 10
)

# then plot them both together
p_df <- tibble(
  x = seq(from = -5, to = 5, length.out = 100)
)

p1 <- ggplot(p_df, aes(x = x)) +
  stat_function(
    fun = function(x) subposterior_one(x) / nc_subpost_one$value,
    n = 501,
    mapping = aes(col = "ppost1"),
  ) +
  stat_function(
    fun = function(x) subposterior_two(x) / nc_subpost_two$value,
    n = 501,
    mapping = aes(col = "ppost2")
  ) +
  stat_function(
    fun = function(x) stage_one_target(x) / nc_target_one$value,
    n = 501,
    mapping = aes(col = "ptarget1")
  ) +
  scale_colour_manual(
    labels = parsed_map(c(
      "ppost1" = "'p'[1](phi~'|'~'Y'[1])",
      "ppost2" = "'p'[2](phi~'|'~'Y'[2])",
      "ptarget1" = "'p'['meld, 1'](phi~'|'~'Y'[1])"
    )),
    values = c(
      "ppost1" = as.character(blues['mid']),
      "ppost2" = greens[2],
      "ptarget1" = highlight_col
    )
  ) +
  xlab(expression(phi)) +
  NULL

ggsave_halfheight(
  filename = "plots/norm-norm-ex/subposteriors.pdf",
  plot = p1
)

## Fri  5 Jul 12:07:41 2019 - the following is a bit rubbish and needs re writing
## I guess I should make sure it works first? 
## Difficult - as it "working" involves me understanding exactly what's going on

# now - lets define a slightly weird u(x)
u_1 <- function(phi, safe_fac = 3, log_scale = TRUE) {
  N <- length(stage_one_data$y)
  k <- safe_fac
  mu_y_1 <- mean(stage_one_data$y)
  var_y_1 <- var(stage_one_data$y)
  mu_y_2 <- mean(stage_two_data$y)
  var_y_2 <- var(stage_two_data$y)
  
  log_res <- dnorm(phi, mean = mu_y_2, sd = sqrt(var_y_2), log = TRUE) -
      (N - k) * dnorm(phi, mean = mu_y_1, sd = sqrt(var_y_1), log = TRUE)
  
  if (log_scale) {
    return(log_res)
  } else {
    return(exp(log_res))
  }
}

augmented_target <- function(phi, safe_fac = 3, log_scale = FALSE) {
  log_res <- stage_one_target(phi, TRUE) + u_1(phi, safe_fac, TRUE)

  if (log_scale) {
    return(log_res)
  } else {
    return(exp(log_res))
  }

}

some_k <- 1:4
various_u <- do.call(c, lapply(some_k, function(a_k) {
  u_1(p_df$x, safe_fac = a_k, log_scale = T)
}))
various_targets <- do.call(c, lapply(some_k, function(a_k) {
  augmented_target(p_df$x, safe_fac = a_k, log_scale = T)
}))

new_df <- data.frame(
  x = p_df$x,
  y = various_u,
  k = as.factor(rep(some_k, each = length(p_df$x))),
  type = "u_function",
  stringsAsFactors = FALSE
)

target_df <- data.frame(
  x = p_df$x,
  y = various_targets,
  k = as.factor(rep(some_k, each = length(p_df$x))),
  type = "augmented_target",
  stringsAsFactors = FALSE
)

combo_df <- rbind(new_df, target_df)

u_p_aug_plot <- ggplot(combo_df, aes(x = x, y = y, col = k)) +
  geom_line() +
  facet_wrap(
    . ~ fct_rev(type),
    scales = "free_y"
  ) +
  ylab("") +
  xlab(expression(phi)) +
  NULL
  
## TODO: Improve this plot once i'm convinced this idea has legs

ggsave_halfheight(
  file = "plots/norm-norm-ex/u-function-augmented-target.pdf",
  plot = u_p_aug_plot
)
