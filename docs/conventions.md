# Conventions

Units:

```text
G = c = M = 1
eps = 1/c bookkeeping parameter
s = 1/r
```

Parameters:

```text
En      reduced orbital energy
L       reduced angular momentum
nu      symmetric mass ratio
delta   mass difference parameter, normally sqrt(1 - 4 nu)
chiS    symmetric aligned-spin combination
chiA    antisymmetric aligned-spin combination
kappaS  symmetric spin-induced quadrupole parameter
kappaA  antisymmetric spin-induced quadrupole parameter
SO      spin bookkeeping parameter
```

Unbound model:

```text
En > 0
r(u) = ar (er cosh u - 1)
```

Bound model:

```text
En < 0
0 < sqrt(1 + 2 En L^2) < 1
r(u) = ar (1 - er cos u)
```

Parabolic model:

```text
En = 0
s = s_p/(1 + w^2)
r(w) = r_p (1 + w^2)
```

Angular equation:

```text
phi - phi0 = K [v + fPhi sin(2v) + gPhi sin(3v)
                  + hPhi sin(4v) + iPhi sin(5v)]
```

Unbound time basis:

```text
n (t - t0) = et sinh(u) - u
           + gt v + ft sin(v) + ht sin(2v) + it sin(3v)
```

Bound time basis:

```text
n (t - t0) = u - et sin(u)
           + gt (v - u) + ft sin(v) + ht sin(2v) + it sin(3v)
```

Parabolic basis:

```text
t - t0 = t(w)
phi - phi0 = phi(w)
```

Newtonian Barker limit:

```text
r(w)   = L^2 (1 + w^2)/2
t(w)   = L^3 (w + w^3/3)/2
phi(w) = 2 ArcTan[w]
```
