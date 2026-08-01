# 3D Spinning-Binary Numerical Module Notes

`src/SpinningBinary3PNOrbits.wl` is a direct numerical 3D module for
comparable-mass binaries with generic spin directions.  It is separate from
the aligned-spin QK model and from the Will-Maitra EMRI module.

## State And Parameters

The integrated state is

```text
x, v, S1, S2
```

in units `G=c=M=1`.  The public initial data can be either Cartesian `x,v` or
spherical

```text
r, theta, phi, rdot, thetadot, phidot
```

together with either physical spin vectors `S1,S2` or dimensionless spin
vectors `chi1Vec,chi2Vec`.  The conversion is

```text
S_A = X_A^2 chi_A,    X1=(1+delta)/2,    X2=(1-delta)/2.
```

## Current Dynamics

The nonspinning acceleration is generated from the already validated
`DirectEOMOrbits.wl` harmonic polar EOM in the spin-zero limit and lifted to
3D as

```text
a = a_r n + a_lambda lambda
```

using the instantaneous radial and tangential directions.  This gives the
nonspinning harmonic content through 3PN.

The implemented generic-spin acceleration currently includes

```text
SO 1.5PN   BMFB/Kidder leading spin-orbit term
SO 2.5PN   BMFB next-to-leading spin-orbit term
SS 2PN     BFMP leading spin-spin/quadrupole term
SS 3PN     BFMP next-to-leading spin-spin/quadrupole term
```

The spin vectors are evolved with the leading norm-preserving spin-orbit
precession equation.  This is enough to test and use precessing-spin
trajectories at the currently implemented generic-spin level, but it is not
yet the complete generic precessing-spin 3PN dynamics.

Remaining work for complete generic precessing-spin 3PN:

```text
1. Add higher-order spin precession equations consistently with the selected
   spin variables.
```

## Validation

Local validation verifies:

```text
1. The spin-zero 3D limit agrees with DirectEOMOrbits through 3PN.
2. The aligned-spin 3D limit agrees with DirectEOMOrbits through 3PN.
3. Nonparallel spins evolve and their magnitudes are conserved by the
   precession equation.
4. OsculatingElements3D can analyze SpinningBinary3PN output.
5. The unified Numerical3DOrbit dispatcher can run both SpinningBinary3PN and
   WillEMRI.
```
