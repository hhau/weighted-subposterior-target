data {
  int <lower = 0> n_y;
  vector [n_y] y;

  // incase I decided to change things later
  real <lower = 0> sd_y;
}

parameters {
  real phi;
}

model {
  target += normal_lpdf(y | phi, sd_y);
}
