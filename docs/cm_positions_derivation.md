# Center-Of-Mass Position Derivation

This note derives the implementation in `src/CMPositions.wl` from the
literature formulas used by the release.

## Starting Point

The PN center-of-mass positions are written in terms of the relative position
and velocity as

$$
\vec{y}_1=X_2\vec{x}+\vec{z},\qquad
\vec{y}_2=-X_1\vec{x}+\vec{z},
$$

with

$$
X_1=\frac{m_1}{M}=\frac{1+\delta}{2},\qquad
X_2=\frac{m_2}{M}=\frac{1-\delta}{2}.
$$

The release uses

$$
G=c=M=1,\qquad
\vec{x}=r\vec{n},\qquad
\vec{v}=\dot r\vec{n}+r\dot\phi\vec{\lambda},\qquad
v^2=\dot r^2+(r\dot\phi)^2.
$$

The bookkeeping parameter `eps` is kept explicitly:

$$
1{\rm PN}\sim \epsilon^2,\quad
1.5{\rm PN}\sim \epsilon^3,\quad
2{\rm PN}\sim \epsilon^4,\quad
2.5{\rm PN}\sim \epsilon^5,\quad
3{\rm PN}\sim \epsilon^6.
$$

## Nonspinning Map

Blanchet's review gives the nonspinning center-of-mass relation in the form

$$
\vec{y}_1=
\left[X_2+\nu\delta{\cal P}\right]\vec{x}
+\nu\delta{\cal Q}\vec{v},
\qquad
\vec{y}_2=
\left[-X_1+\nu\delta{\cal P}\right]\vec{x}
+\nu\delta{\cal Q}\vec{v}.
$$

Therefore

$$
\vec{z}_{\rm NS}
=\nu\delta\left({\cal P}\vec{x}+{\cal Q}\vec{v}\right).
$$

In release units, with $s=1/r$,

$$
{\cal P}_{1{\rm PN}}=\frac{v^2}{2}-\frac{s}{2},
$$

$$
{\cal P}_{2{\rm PN}}
=\frac{3v^4}{8}-\frac{3\nu v^4}{2}
+s\left(-\frac{\dot r^2}{8}+\frac{3\nu\dot r^2}{4}
+\frac{19v^2}{8}+\frac{3\nu v^2}{2}\right)
+s^2\left(\frac{7}{4}-\frac{\nu}{2}\right),
$$

$$
\begin{aligned}
{\cal P}_{3{\rm PN}}={}&
\frac{5v^6}{16}-\frac{11\nu v^6}{4}+6\nu^2v^6 \\
&+s\left(
\frac{\dot r^4}{16}-\frac{5\nu\dot r^4}{8}
+\frac{21\nu^2\dot r^4}{16}
-\frac{5\dot r^2v^2}{16}
+\frac{21\nu\dot r^2v^2}{16}
-\frac{11\nu^2\dot r^2v^2}{2}
+\frac{53v^4}{16}-7\nu v^4-\frac{15\nu^2v^4}{2}
\right)\\
&+s^2\left(
-\frac{7\dot r^2}{3}
+\frac{73\nu\dot r^2}{8}
+4\nu^2\dot r^2
+\frac{101v^2}{12}
-\frac{33\nu v^2}{8}
+3\nu^2v^2
\right)\\
&+s^3\left(
-\frac{14351}{1260}+\frac{\nu}{8}-\frac{\nu^2}{2}
+\frac{22}{3}\ln\frac{r}{r'_0}
\right).
\end{aligned}
$$

The corresponding conservative ${\cal Q}$ terms retained by default are

$$
{\cal Q}_{2{\rm PN}}=-\frac{7\dot r}{4},
$$

$$
{\cal Q}_{3{\rm PN}}
=\dot r\left(
\frac{5\dot r^2}{12}
-\frac{19\nu\dot r^2}{24}
-\frac{15v^2}{8}
+\frac{21\nu v^2}{4}
\right)
+s\dot r\left(-\frac{235}{24}-\frac{21\nu}{4}\right).
$$

The dissipative nonspinning 2.5PN CM term from the same source is

$$
{\cal Q}_{2.5{\rm PN}}=\frac{4v^2}{5}-\frac{8s}{5}.
$$

It is not included in conservative QK use.  The release only includes it when

```wl
"Include2p5PNRadiationReaction" -> True
```

is passed to `CMPositionsFromRelativeOrbit`.

## Spin-Orbit Map

BMFB write the spin-orbit part of the same shift as

$$
\vec{z}_{\rm SO}
=-\nu\epsilon^3(\vec{\Sigma}\times\vec{v})
+\nu\epsilon^5\left[
\left(-\frac12+2\nu\right)v^2(\vec{\Sigma}\times\vec{v})
+s\,\vec{Y}_{2.5}
\right],
$$

where

$$
\begin{aligned}
\vec{Y}_{2.5}={}&
\delta(\vec n,\vec S,\vec v)\vec n
-\frac32\delta\dot r(\vec n\times\vec S)
+(-1+4\nu)\dot r(\vec n\times\vec\Sigma)\\
&-\frac12\delta(\vec S\times\vec v)
+(-2-\nu)(\vec\Sigma\times\vec v).
\end{aligned}
$$

The spin combinations are

$$
\vec S=\vec S_1+\vec S_2,\qquad
\vec\Sigma=M\left(\frac{\vec S_2}{m_2}-\frac{\vec S_1}{m_1}\right).
$$

For aligned dimensionless spins in the release convention,

$$
\vec S_A=m_A^2\chi_A\vec\ell,\qquad M=1.
$$

Thus

$$
S_\ell=X_1^2\chi_1+X_2^2\chi_2
=\frac{\chi_1(1+\delta-2\nu)+\chi_2(1-\delta-2\nu)}{2},
$$

and

$$
\Sigma_\ell=X_2\chi_2-X_1\chi_1
=\frac{-\chi_1(1+\delta)+\chi_2(1-\delta)}{2}.
$$

These are exactly the `Sl` and `SigmaL` combinations used by the release EOM
and by `CMPositions.wl`.

## Aligned-Spin Projection

Use the right-handed triad

$$
\vec n=(\cos\phi,\sin\phi),\qquad
\vec\lambda=(-\sin\phi,\cos\phi),\qquad
\vec\ell=\vec n\times\vec\lambda.
$$

For any scalar $a$,

$$
a\vec\ell\times(v_x,v_y)=a(-v_y,v_x),
$$

and

$$
(v_x,v_y)\times a\vec\ell=a(v_y,-v_x).
$$

Therefore

$$
\vec S\times\vec v
=S_\ell\vec\ell\times\vec v,\qquad
\vec\Sigma\times\vec v
=\Sigma_\ell\vec\ell\times\vec v,
$$

$$
\vec n\times\vec S=\vec n\times S_\ell\vec\ell,\qquad
\vec n\times\vec\Sigma=\vec n\times\Sigma_\ell\vec\ell,
$$

and

$$
(\vec n,\vec S,\vec v)
=\vec n\cdot(\vec S\times\vec v).
$$

This is the direct rule implemented by

```wl
ellCrossVec[a_, vec_] := a*{-vec[[2]], vec[[1]]}
vecCrossEll[vec_, a_] := a*{vec[[2]], -vec[[1]]}
tripleS = nvec . ellCrossVec[Sl, vvec]
```

in `CMPositions.wl`.

## Final Release Formula

The implemented shift is

$$
\vec z =
\nu\delta\left[
\left(\epsilon^2{\cal P}_{1{\rm PN}}
+\epsilon^4{\cal P}_{2{\rm PN}}
+\epsilon^6{\cal P}_{3{\rm PN}}\right)\vec x
+\left(\epsilon^4{\cal Q}_{2{\rm PN}}
+\epsilon^6{\cal Q}_{3{\rm PN}}\right)\vec v
\right]
+\vec z_{\rm SO},
$$

with an optional extra term

$$
\nu\delta\,\epsilon^5{\cal Q}_{2.5{\rm PN}}\vec v
$$

when the dissipative option is enabled.

Finally,

$$
\vec y_1=X_2\vec x+\vec z,\qquad
\vec y_2=-X_1\vec x+\vec z.
$$

This automatically gives the exact identity

$$
\vec y_1-\vec y_2=\vec x
$$

at every retained PN order, because the same shift $\vec z$ is added to both
particles.

## Boost-Integral Validation

The implementation was independently validated from the conserved boost, or mass-dipole, integral.  The nonspinning calculation encodes the BI02CM general-frame center-of-mass vector $G^i$ through 3PN and inserts

$$
\vec y_1=X_2\vec x+\vec z,\qquad
\vec y_2=-X_1\vec x+\vec z,
$$

It then solves $G^i=0$ order by order and reproduces
${\cal P}_{1{\rm PN}}$, ${\cal P}_{2{\rm PN}}$, ${\cal Q}_{2{\rm PN}}$,
${\cal P}_{3{\rm PN}}$, ${\cal Q}_{3{\rm PN}}$, and the optional
${\cal Q}_{2.5{\rm PN}}$ radiation-reaction CM term.

The spin calculation encodes the BMFB spin-orbit boost integral $G_S^i$ at 1.5PN and 2.5PN.  In the aligned-spin restriction it solves $G^i=0$ and reproduces the SO shift used by `CMPositions.wl`.

## Sources

- L. Blanchet and B. R. Iyer, "Third post-Newtonian dynamics of compact binaries: equations of motion in the center-of-mass frame", arXiv:gr-qc/0209089.
- L. Blanchet, Living Reviews in Relativity review, center-of-mass relation section containing the 4PN ${\cal P},{\cal Q}$ formula; this release truncates it at 3PN plus optional 2.5PN dissipative ${\cal Q}$.
- A. Bohe, S. Marsat, G. Faye, and L. Blanchet, "Next-to-next-to-leading order spin-orbit effects in the near-zone metric and precession equations of compact binaries", arXiv:1212.5520.
- L. Blanchet, G. Faye, S. Marsat, and E. K. Porter, "Quadratic-in-spin effects in the orbital dynamics and gravitational-wave energy flux of compact binaries at the 3PN order", arXiv:1501.01529.  This is the reason no separate SS 3PN individual-position shift is added for the current aligned-spin CM reduction.
