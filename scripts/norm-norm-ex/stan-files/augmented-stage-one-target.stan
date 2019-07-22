data {
  int <lower = 0> n_y;
  vector [n_y] y;

  // incase I decided to change things later
  real <lower = 0> sd_y;

  // weighting
  real y_1_mean;
  real <lower = 0> y_1_sd;
  real y_2_mean;
  real <lower = 0> y_2_sd;
  int <upper = n_y - 1> k;

  real mu_u;
  real <lower = 0> sd_u;
}

parameters {
  real phi;
}

model {
  // likelihood
  target += normal_lpdf(y | phi, sd_y);

  // subposterior weighting
  target += normal_lpdf(phi | mu_u, sd_u);
  target += -(n_y - k) * normal_lpdf(phi | y_1_mean, y_1_sd);
}