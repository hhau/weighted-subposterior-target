model_one_samples <- readRDS("rds/norm-norm-ex/with-u-2/phi-samples-model-one.rds")
model_two_samples <- readRDS("rds/norm-norm-ex/with-u-2/phi-samples-model-two.rds")

safe_fac <- 1.0

mu_1 <- mean(model_one_samples)
var_1 <- var(model_one_samples)
mu_2 <- mean(model_two_samples)
var_2 <- var(model_two_samples)

mu_de <- mu_1
var_de <- var_1 * safe_fac

mu_nu <- (mu_1 * var_2 + mu_2 * var_1) / (var_1 + var_2)
var_nu <- ((var_1 * var_2) / (var_1 + var_2)) * 1.7

u_func_args <- list(
  mu_de = mu_de,
  var_de = var_de,
  mu_nu = mu_nu,
  var_nu = var_nu
)

saveRDS(
  object = u_func_args,
  file = "rds/norm-norm-ex/with-u-2/u-func-args.rds"
)