data {
  int <lower = 0> n_y;
  vector [n_y] y;

  // incase I decided to change things later
  real <lower = 0> sd_y;

  // weighting
  real mu_nu;
  real <lower = 0> sd_nu;

  real mu_de;
  real <lower = 0> sd_de;
}

parameters {
  real phi;
}

model {
  // likelihood
  target += normal_lpdf(y | phi, sd_y);

  // subposterior weighting
  target += normal_lpdf(phi | mu_nu, sd_nu);
  target += -1 * normal_lpdf(phi | mu_de, sd_de);
}
