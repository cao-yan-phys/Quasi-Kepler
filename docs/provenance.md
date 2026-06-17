# Provenance

This prototype packages the current working results into a reusable calculator.

## Nonspinning 3PN MH Sector

The nonspinning 3PN modified-harmonic bound and unbound QK sectors were derived
directly from the reduced first-integral dynamics and checked against known MGS
harmonic/MH results.

## 2023 Aligned-Spin Sectors

The aligned-spin first integrals were extracted from the 2023 ancillary
energy/angular-momentum data and checked against the SO/SS acceleration sources.

For the spin QK angular/time sectors, the current workflow uses the 2023 bound
QK expressions as candidates and verifies them by direct first-integral
residuals.  The unbound spin sector is obtained by the structurally derived
bound-to-unbound map and then checked by direct residuals and numerical orbit
comparisons.

So the honest label is:

```text
3PN nonspin MH + verified 2023 aligned-spin sectors
```

not:

```text
fully independent first-principles spin QK coefficient derivation
```

## Merged Models

The release models merge:

```text
pure nonspinning MH 3PN block
+ 2023 aligned-spin sectors
```

This is a PN-order merge.  The retained spin sectors are SO eps^3/eps^5 and SS
eps^4/eps^6.

## Parabolic Model

The parabolic model is the conservative marginally bound `En = 0` limit.  It
uses the Barker anomaly

```text
s = s_p/(1 + w^2)
```

and the directly integrated result for `t(w)` and `phi(w)`.  Radiation reaction
is not included.
