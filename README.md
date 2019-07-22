# Weighted subposterior targets

Conflicting subposteriors are an issue for Markov melding, as the samples from the `m-1`th melded subposterior are used as a proposal for the `m`th melded (sub)posterior.
If the support of the former does not intersect with the support of the latter, the resulting sample is degenerate <sup id="a1">[1](#degenerate)</sup>. 
 
<b id="degenerate">1</b>: 'Degenerate' in the same way that SMC samplers can suffer from the particle degeneracy problem unless MCMC kernel refreshment is used. [↩](#degenerate)