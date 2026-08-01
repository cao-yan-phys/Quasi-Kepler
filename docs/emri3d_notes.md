# Independent 3D EMRI Module Notes

This note records the formula sources and checks for `src/EMRI3DOrbits.wl`.
The module is independent of the aligned-spin QK models.

## EOM Source

The conservative 3D acceleration is taken from Clifford M. Will and Matthew
Maitra, "Relativistic orbits around spinning supermassive black holes. Secular
evolution to 4.5 post-Newtonian order", arXiv:1611.06931, Eq. (2.2).

Conventions used in the implementation:

```text
G = c = M = 1 by default
eps = 1/c bookkeeping parameter, default eps -> 1
x, v are harmonic-coordinate test-body position and velocity
chi is the Kerr spin parameter
spinDirection is the fixed unit vector along the central black-hole spin
```

The retained conservative content is

```text
0PN      Newtonian monopole
1PN      Schwarzschild/test-body monopole
1.5PN    spin-orbit/frame-dragging, linear in chi
2PN      monopole plus leading chi^2 quadrupole
2.5PN    spin-orbit, linear in chi
3PN      monopole plus chi^2 cross/spin-squared terms
```

The optional dissipative sector is the Will-Maitra Eq. (2.3) radiation
reaction through 4.5PN:

```text
2.5PN   nonspinning radiation reaction
3.5PN   nonspinning radiation reaction
4PN     spin-orbit radiation reaction
4.5PN   nonspinning radiation reaction
```

Use `"IncludeRadiationReaction" -> True` to include all terms up to the
requested `PNOrder`.  The compatibility switch
`"Include2p5PNRadiationReaction" -> True` adds only the leading 2.5PN term.
The 4.5PN gauge parameters of Will-Maitra Appendix B can be supplied through
`"RRGaugeParameters" -> <|"psi1" -> ..., "chi6" -> ..., ...|>`.

## Osculating-Element Definitions

The public element labels follow Ya-Ze Cheng, Yan Cao, and Yong Tang,
"Effects of black hole environments on extreme mass-ratio hyperbolic
encounters", arXiv:2411.03095v3.

The supported labels are

```text
a          positive semimajor-axis magnitude
e          eccentricity
i          inclination relative to the fixed reference plane
phi0       Cheng-Cao-Tang node label; phi0 - Pi/2 is the standard longitude
           of the ascending node
varphi0    argument of periastron on the orbital plane
varphi     true anomaly
p          semilatus rectum, optional
```

For hyperbolic elements the module uses

```text
r = a (e^2 - 1)/(1 + e cos(varphi))
M_anomaly = e sinh(xi) - xi
Omega_K = Sqrt[M/a^3]
```

For bound elements it uses the same instantaneous Newtonian osculating-state
map with `p = a (1 - e^2)`.

`EMRI3DHyperbolicGaussianRates` implements the hyperbolic Gaussian
perturbation equations of arXiv:2411.03095v3 Appendix A.  It accepts either
an inertial perturbing force vector or the projected components
`Fr`, `Fvarphi`, `FZ`.

## Validation

Local validation verifies:

```text
1. The 1PN acceleration equals arXiv:2411.03095v3 Eq. (4) in the nu -> 0
   test-body limit.
2. The optional 2.5PN radiation-reaction acceleration equals
   arXiv:2411.03095v3 Eq. (5).
3. The full Will radiation-reaction switch adds higher-order 3.5PN/4PN/4.5PN
   terms beyond the isolated 2.5PN switch.
4. The leading spin acceleration equals arXiv:2411.03095v3 Eq. (A.8) in the
   EMRI limit q -> 0, and hence Will-Maitra Eq. (2.2) at 1.5PN.
5. Osculating elements round-trip through state -> elements -> state.
6. In a tilted Newtonian orbit, p, e, and i remain constant to numerical
   integration accuracy.
7. In the nonspinning equatorial test-body limit, the 3PN 3D EMRI integration
   agrees with the existing 2D direct polar EOM at the tested short-time
   tolerance.
```
