data {
  // data
  int <lower = 0> n_y_1;
  int <lower = 0> n_y_2;
  vector [n_y_1] y_1;
  vector [n_y_2] y_2;

  // hyperprior things (really don't want to recode this if necessary)
  real <lower = 0> sigma_1;
  real <lower = 0> sigma_2;
  real mu_phi_1;
  real mu_phi_2;
  real <lower = 0> sigma_phi_1;
  real <lower = 0> sigma_phi_2;
   
}

parameters {
  real phi;
}

model {
  //ppool bit
  target += log_mix(
    0.5,
    normal_lpdf(phi | mu_phi_1, sigma_phi_1),
    normal_lpdf(phi | mu_phi_2, sigma_phi_2)
  );

  // likelihoods
  target += normal_lpdf(y_1 | phi, sigma_1);
  target += normal_lpdf(y_2 | phi, sigma_2);

  // everything else cancels
}