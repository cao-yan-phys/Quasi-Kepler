<|"metadata" -> 
  <|"status" -> 
    "direct acceleration polar EOM, conservative aligned-spin through 3PN", 
   "coordinateGauge" -> 
    "modified harmonic for nonspinning 3PN; harmonic spin sectors", 
   "variables" -> <|"s" -> "1/r", "rd" -> "dr/dt", "p" -> "dphi/dt", 
     "vt" -> "r dphi/dt = p/s", "v2" -> "rd^2 + vt^2", "eps" -> "1/c"|>, 
   "spinBasis" -> <|"delta" -> "(m1-m2)/(m1+m2), with delta^2=1-4 nu", 
     "chi1" -> "aligned dimensionless spin of body 1", 
     "chi2" -> "aligned dimensionless spin of body 2", 
     "kap1" -> "spin-induced quadrupole parameter of body 1", 
     "kap2" -> "spin-induced quadrupole parameter of body 2"|>, 
   "sources" -> <|"nonspin" -> 
      "Blanchet LRR 2024, Eqs. (dvdt), (calAcoeff), (calBcoeff), (ABcoeffMH)"\
, "SO" -> "Bohe et al. 1212.5520, AiSCMc3.tex and AiSCMc5.tex", 
     "SS" -> "Blanchet, Faye, Marsat, Porter 1501.01529, CM acceleration \
lines 2750-2963"|>, "important" -> "This file is built from direct \
acceleration formulae, not from R(s), P(s) first integrals."|>, 
 "definitions" -> <|"vt" -> p/s, "v2" -> rd^2 + p^2/s^2, 
   "Sl" -> (chi2*(1 - delta - 2*nu))/2 + (chi1*(1 + delta - 2*nu))/2, 
   "SigmaL" -> (chi1*(-1 - delta))/2 + (chi2*(1 - delta))/2|>, 
 "nonspinAB" -> <|"A1MH" -> ((2 + 3*nu)*rd^2)/2 + ((1 + 3*nu)*p^2)/s^2 - 
     2*(2 + nu)*s, "B1MH" -> 2*(-2 + nu)*rd, 
   "A2MH" -> ((3*nu - 29*nu^2)*rd^4)/8 + ((3*nu - 4*nu^2)*p^4)/s^4 + 
     ((3*nu - 4*nu^2)*p^2*rd^2)/(2*s^2) + ((-13*nu + 4*nu^2)*p^2)/(2*s) + 
     ((-4 - 63*nu)*rd^2*s)/2 + (3*(12 + 29*nu)*s^2)/4, 
   "B2MH" -> (-3*nu + nu^2)*rd^3 + ((-15*nu - 4*nu^2)*p^2*rd)/(2*s^2) + 
     ((4 + 41*nu + 8*nu^2)*rd*s)/2, 
   "A3MH" -> (p^2*(-166616*nu + 6720*nu^3 - 12915*nu*Pi^2))/6720 + 
     (3*(3*nu - 29*nu^2 + 61*nu^3)*rd^6)/16 + 
     ((11*nu - 49*nu^2 + 52*nu^3)*p^6)/(4*s^6) + 
     (3*(2*nu - 19*nu^2 + 44*nu^3)*p^4*rd^2)/(8*s^4) + 
     ((75*nu + 32*nu^2 - 40*nu^3)*p^4)/(4*s^3) + 
     (3*(2*nu - 30*nu^2 + 69*nu^3)*p^2*rd^4)/(8*s^2) + 
     ((-167*nu + 64*nu^2)*p^2*rd^2)/(2*s) + 
     ((-93*nu - 42*nu^2 - 80*nu^3)*rd^4*s)/4 + 
     ((1680 + 185516*nu + 2310*nu^2 - 10080*nu^3 + 12915*nu*Pi^2)*rd^2*s^2)/
      1680 + ((-768 - 5596*nu - 1704*nu^2 + 123*nu*Pi^2)*s^3)/48, 
   "B3MH" -> ((-7*nu + 25*nu^2 - 9*nu^3)*rd^5)/4 + 
     ((-65*nu + 152*nu^2 + 48*nu^3)*p^4*rd)/(8*s^4) + 
     ((-17*nu + 41*nu^2)*p^2*rd^3)/(4*s^2) + 
     ((-15*nu - 27*nu^2 - 10*nu^3)*p^2*rd)/s + 
     ((239*nu + 15*nu^2 + 48*nu^3)*rd^3*s)/6 + 
     ((-13440 - 23396*nu + 84000*nu^2 + 26880*nu^3 - 12915*nu*Pi^2)*rd*s^2)/
      3360|>, "spinBlocks" -> 
  <|"SO_b15" -> {((chi2*(1 - delta + nu) + chi1*(1 + delta + nu))*p)/s, 
     (chi1*(-1 - delta + 2*nu) + chi2*(-1 + delta + 2*nu))*rd, 0}, 
   "SO_b25b1" -> {(((-5*chi2*(-nu + delta*nu))/2 + (5*chi1*(nu + delta*nu))/
          2)*p^3)/s^3 + 
      (((chi2*(-12 + 12*delta + 13*nu - delta*nu + 18*nu^2))/4 + 
         (chi1*(-12 - 12*delta + 13*nu + delta*nu + 18*nu^2))/4)*p*rd^2)/s, 
     (chi1*(-nu - delta*nu + 3*nu^2) + chi2*(-nu + delta*nu + 3*nu^2))*rd^3 + 
      (((chi2*(-6 + 6*delta + 7*nu - delta*nu))/2 + 
         (chi1*(-6 - 6*delta + 7*nu + delta*nu))/2)*p^2*rd)/s^2, 0}, 
   "SO_b25b2" -> {(((chi1*(-8 - 8*delta - 13*nu - 5*delta*nu - 8*nu^2))/2 + 
        (chi2*(-8 + 8*delta - 13*nu + 5*delta*nu - 8*nu^2))/2)*p)/s, 
     (-2*chi2*(-1 + delta + nu + delta*nu - nu^2) + 
       2*chi1*(1 + delta - nu + delta*nu + nu^2))*rd, 0}, 
   "SS_alpha40n" -> chi1*chi2*((3*(-1 + delta^4 - 16*nu^2))/2 + 
       (3*kap1*(-1 + delta^4 + 8*nu - 16*nu^2))/4 + 
       (3*kap2*(-1 + delta^4 + 8*nu - 16*nu^2))/4) + 
     chi2^2*((3*(-1 + 2*delta - 2*delta^3 + delta^4 + 8*nu - 8*delta*nu - 
          16*nu^2))/4 + (3*kap1*(-1 + 2*delta - 2*delta^3 + delta^4 + 8*nu - 
          8*delta*nu - 16*nu^2))/8 + (3*kap2*(-9 + 10*delta - 2*delta^3 + 
          delta^4 + 24*nu - 8*delta*nu - 16*nu^2))/8) + 
     chi1^2*((3*(-1 - 2*delta + 2*delta^3 + delta^4 + 8*nu + 8*delta*nu - 
          16*nu^2))/4 + (3*kap2*(-1 - 2*delta + 2*delta^3 + delta^4 + 8*nu + 
          8*delta*nu - 16*nu^2))/8 + (3*kap1*(-9 - 10*delta + 2*delta^3 + 
          delta^4 + 24*nu + 8*delta*nu - 16*nu^2))/8), 
   "SS_alpha60n" -> 
    (chi1*chi2*((3*kap1*(-14 + 4*delta - 8*delta^3 + 14*delta^4 + 4*delta^5 + 
            111*nu - 16*delta*nu + 16*delta^3*nu + delta^4*nu - 216*nu^2 - 
            16*nu^3))/4 + (3*(22 - 22*delta^4 - 193*nu + delta^4*nu + 
            352*nu^2 - 16*nu^3))/2 - (3*kap2*(14 + 4*delta - 8*delta^3 - 
            14*delta^4 + 4*delta^5 - 111*nu - 16*delta*nu + 16*delta^3*nu - 
            delta^4*nu + 216*nu^2 + 16*nu^3))/4) + 
       chi1^2*((3*kap1*(-46 - 80*delta + 60*delta^3 + 30*delta^4 + 
            4*delta^5 + 199*nu + 182*delta*nu + 18*delta^3*nu + delta^4*nu - 
            456*nu^2 + 8*delta*nu^2 - 16*nu^3))/8 + 
         (3*(22 + 60*delta - 60*delta^3 - 22*delta^4 - 113*nu - 
            178*delta*nu + 2*delta^3*nu + delta^4*nu + 360*nu^2 + 
            8*delta*nu^2 - 16*nu^3))/4 - (3*kap2*(-2 + 8*delta - 12*delta^3 + 
            2*delta^4 + 4*delta^5 + 17*nu - 30*delta*nu + 14*delta^3*nu - 
            delta^4*nu - 40*nu^2 - 8*delta*nu^2 + 16*nu^3))/8) + 
       chi2^2*((3*kap1*(2 + 8*delta - 12*delta^3 - 2*delta^4 + 4*delta^5 - 
            17*nu - 30*delta*nu + 14*delta^3*nu + delta^4*nu + 40*nu^2 - 
            8*delta*nu^2 - 16*nu^3))/8 + (3*(22 - 60*delta + 60*delta^3 - 
            22*delta^4 - 113*nu + 178*delta*nu - 2*delta^3*nu + delta^4*nu + 
            360*nu^2 - 8*delta*nu^2 - 16*nu^3))/4 - 
         (3*kap2*(46 - 80*delta + 60*delta^3 - 30*delta^4 + 4*delta^5 - 
            199*nu + 182*delta*nu + 18*delta^3*nu - delta^4*nu + 456*nu^2 + 
            8*delta*nu^2 + 16*nu^3))/8))*rd^2 + 
     ((chi1*chi2*((3*kap2*(1 + delta - 2*delta^3 - delta^4 + delta^5 - 
             14*nu - 4*delta*nu + 4*delta^3*nu + 6*delta^4*nu + 64*nu^2 - 
             96*nu^3))/4 + 3*(-4 + 4*delta^4 + 21*nu + 3*delta^4*nu - 
            64*nu^2 - 48*nu^3) - (3*kap1*(-1 + delta - 2*delta^3 + delta^4 + 
             delta^5 + 14*nu - 4*delta*nu + 4*delta^3*nu - 6*delta^4*nu - 
             64*nu^2 + 96*nu^3))/4) + 
        chi1^2*((3*kap2*(-3 - 3*delta + 2*delta^3 + 3*delta^4 + delta^5 + 
             18*nu + 16*delta^3*nu + 6*delta^4*nu + 48*delta*nu^2 - 96*nu^3))/
           8 + (3*(-4 - 10*delta + 10*delta^3 + 4*delta^4 + 21*nu + 
             26*delta*nu + 6*delta^3*nu + 3*delta^4*nu - 40*nu^2 + 
             24*delta*nu^2 - 48*nu^3))/2 - 
          (3*kap1*(11 + 5*delta + 10*delta^3 + 5*delta^4 + delta^5 + 46*nu + 
             88*delta*nu - 8*delta^3*nu - 6*delta^4*nu - 224*nu^2 - 
             48*delta*nu^2 + 96*nu^3))/8) + 
        chi2^2*((3*kap2*(-11 + 5*delta + 10*delta^3 - 5*delta^4 + delta^5 - 
             46*nu + 88*delta*nu - 8*delta^3*nu + 6*delta^4*nu + 224*nu^2 - 
             48*delta*nu^2 - 96*nu^3))/8 + (3*(-4 + 10*delta - 10*delta^3 + 
             4*delta^4 + 21*nu - 26*delta*nu - 6*delta^3*nu + 3*delta^4*nu - 
             40*nu^2 - 24*delta*nu^2 - 48*nu^3))/2 - 
          (3*kap1*(3 - 3*delta + 2*delta^3 - 3*delta^4 + delta^5 - 18*nu + 
             16*delta^3*nu - 6*delta^4*nu + 48*delta*nu^2 + 96*nu^3))/8))*
       p^2)/s^2, "SS_alpha60Fv" -> 
    chi1*chi2*((3*kap2*(7 + delta - 2*delta^3 - 7*delta^4 + delta^5 - 58*nu - 
          4*delta*nu + 4*delta^3*nu + 2*delta^4*nu + 128*nu^2 - 32*nu^3))/2 + 
       6*(-5 + 5*delta^4 + 47*nu + delta^4*nu - 80*nu^2 - 16*nu^3) - 
       (3*kap1*(-7 + delta - 2*delta^3 + 7*delta^4 + delta^5 + 58*nu - 
          4*delta*nu + 4*delta^3*nu - 2*delta^4*nu - 128*nu^2 + 32*nu^3))/
        2) + chi1^2*((3*kap2*(3 + 9*delta - 10*delta^3 - 3*delta^4 + 
          delta^5 - 26*nu - 40*delta*nu + 8*delta^3*nu + 2*delta^4*nu + 
          64*nu^2 + 16*delta*nu^2 - 32*nu^3))/4 + 
       3*(-5 - 14*delta + 14*delta^3 + 5*delta^4 + 23*nu + 38*delta*nu + 
         2*delta^3*nu + delta^4*nu - 72*nu^2 + 8*delta*nu^2 - 16*nu^3) - 
       (3*kap1*(-43 - 55*delta + 22*delta^3 + 11*delta^4 + delta^5 + 154*nu + 
          96*delta*nu - 2*delta^4*nu - 224*nu^2 - 16*delta*nu^2 + 32*nu^3))/
        4) + chi2^2*((3*kap2*(43 - 55*delta + 22*delta^3 - 11*delta^4 + 
          delta^5 - 154*nu + 96*delta*nu + 2*delta^4*nu + 224*nu^2 - 
          16*delta*nu^2 - 32*nu^3))/4 + 3*(-5 + 14*delta - 14*delta^3 + 
         5*delta^4 + 23*nu - 38*delta*nu - 2*delta^3*nu + delta^4*nu - 
         72*nu^2 - 8*delta*nu^2 - 16*nu^3) - 
       (3*kap1*(-3 + 9*delta - 10*delta^3 + 3*delta^4 + delta^5 + 26*nu - 
          40*delta*nu + 8*delta^3*nu - 2*delta^4*nu - 64*nu^2 + 
          16*delta*nu^2 + 32*nu^3))/4), "SS_alpha61n" -> 
    chi1*chi2*(9 - 9*delta^4 + 5*nu - 5*delta^4*nu + 144*nu^2 + 80*nu^3 + 
       (kap1*(14 - 2*delta + 4*delta^3 - 14*delta^4 - 2*delta^5 - 107*nu + 
          8*delta*nu - 8*delta^3*nu - 5*delta^4*nu + 184*nu^2 + 80*nu^3))/2 + 
       (kap2*(14 + 2*delta - 4*delta^3 - 14*delta^4 + 2*delta^5 - 107*nu - 
          8*delta*nu + 8*delta^3*nu - 5*delta^4*nu + 184*nu^2 + 80*nu^3))/
        2) + chi1^2*((kap2*(6 + 18*delta - 20*delta^3 - 6*delta^4 + 
          2*delta^5 - 43*nu - 62*delta*nu - 2*delta^3*nu - 5*delta^4*nu + 
          56*nu^2 - 40*delta*nu^2 + 80*nu^3))/4 + 
       (9 + 18*delta - 18*delta^3 - 9*delta^4 - 67*nu - 62*delta*nu - 
         10*delta^3*nu - 5*delta^4*nu + 104*nu^2 - 40*delta*nu^2 + 80*nu^3)/
        2 + (kap1*(86 + 110*delta - 44*delta^3 - 22*delta^4 - 2*delta^5 - 
          227*nu - 102*delta*nu - 18*delta^3*nu - 5*delta^4*nu + 232*nu^2 - 
          40*delta*nu^2 + 80*nu^3))/4) + 
     chi2^2*((kap1*(6 - 18*delta + 20*delta^3 - 6*delta^4 - 2*delta^5 - 
          43*nu + 62*delta*nu + 2*delta^3*nu - 5*delta^4*nu + 56*nu^2 + 
          40*delta*nu^2 + 80*nu^3))/4 + (9 - 18*delta + 18*delta^3 - 
         9*delta^4 - 67*nu + 62*delta*nu + 10*delta^3*nu - 5*delta^4*nu + 
         104*nu^2 + 40*delta*nu^2 + 80*nu^3)/2 + 
       (kap2*(86 - 110*delta + 44*delta^3 - 22*delta^4 + 2*delta^5 - 227*nu + 
          102*delta*nu + 18*delta^3*nu - 5*delta^4*nu + 232*nu^2 + 
          40*delta*nu^2 + 80*nu^3))/4)|>, "accelerationSectors" -> 
  <|"aN_nonspin" -> -s^2 + eps^2*((-1 - 3*nu)*p^2 + ((6 - 7*nu)*rd^2*s^2)/2 + 
       2*(2 + nu)*s^3) + eps^4*(2*(3*nu + 2*nu^2)*p^2*rd^2 + 
       ((-3*nu + 4*nu^2)*p^4)/s^2 + ((13*nu - 4*nu^2)*p^2*s)/2 + 
       (21*(nu + nu^2)*rd^4*s^2)/8 + (11*nu - 4*nu^2)*rd^2*s^3 - 
       (3*(12 + 29*nu)*s^4)/4) + 
     eps^6*(((28*nu + 8*nu^2 - 207*nu^3)*p^2*rd^4)/8 + 
       ((-11*nu + 49*nu^2 - 52*nu^3)*p^6)/(4*s^4) + 
       ((59*nu - 95*nu^2 - 180*nu^3)*p^4*rd^2)/(8*s^2) + 
       ((-75*nu - 32*nu^2 + 40*nu^3)*p^4)/(4*s) + 
       ((197*nu - 10*nu^2 + 20*nu^3)*p^2*rd^2*s)/2 + 
       ((p^2*(166616*nu - 6720*nu^3 + 12915*nu*Pi^2))/6720 + 
         ((19*nu - 13*nu^2 - 147*nu^3)*rd^6)/16)*s^2 + 
       ((-199*nu + 96*nu^2 + 144*nu^3)*rd^4*s^3)/12 + 
       ((10080 - 347636*nu - 88620*nu^2 - 6720*nu^3 - 12915*nu*Pi^2)*rd^2*
         s^4)/3360 + ((768 + 5596*nu + 1704*nu^2 - 123*nu*Pi^2)*s^5)/48), 
   "aLambda_nonspin" -> -2*eps^2*(-2 + nu)*p*rd*s + 
     eps^4*(((15*nu + 4*nu^2)*p^3*rd)/(2*s) + (3*nu - nu^2)*p*rd^3*s + 
       ((-4 - 41*nu - 8*nu^2)*p*rd*s^2)/2) + 
     eps^6*((15*nu + 27*nu^2 + 10*nu^3)*p^3*rd + 
       ((65*nu - 152*nu^2 - 48*nu^3)*p^5*rd)/(8*s^3) + 
       ((17*nu - 41*nu^2)*p^3*rd^3)/(4*s) + ((7*nu - 25*nu^2 + 9*nu^3)*p*rd^5*
         s)/4 + ((-239*nu - 15*nu^2 - 48*nu^3)*p*rd^3*s^2)/6 + 
       (p*(13440 + 23396*nu - 84000*nu^2 - 26880*nu^3 + 12915*nu*Pi^2)*rd*
         s^3)/3360), "aN_SO" -> 
    eps^3*(chi2*(1 - delta + nu) + chi1*(1 + delta + nu))*p*s^2 + 
     eps^5*(((-5*chi2*(-nu + delta*nu))/2 + (5*chi1*(nu + delta*nu))/2)*p^3 + 
       ((chi2*(-12 + 12*delta + 13*nu - delta*nu + 18*nu^2))/4 + 
         (chi1*(-12 - 12*delta + 13*nu + delta*nu + 18*nu^2))/4)*p*rd^2*s^2 + 
       ((chi1*(-8 - 8*delta - 13*nu - 5*delta*nu - 8*nu^2))/2 + 
         (chi2*(-8 + 8*delta - 13*nu + 5*delta*nu - 8*nu^2))/2)*p*s^3), 
   "aLambda_SO" -> eps^3*(chi1*(-1 - delta + 2*nu) + 
       chi2*(-1 + delta + 2*nu))*rd*s^3 + 
     eps^5*(((chi2*(-6 + 6*delta + 7*nu - delta*nu))/2 + 
         (chi1*(-6 - 6*delta + 7*nu + delta*nu))/2)*p^2*rd*s + 
       (chi1*(-nu - delta*nu + 3*nu^2) + chi2*(-nu + delta*nu + 3*nu^2))*rd^3*
        s^3 + (-2*chi2*(-1 + delta + nu + delta*nu - nu^2) + 
         2*chi1*(1 + delta - nu + delta*nu + nu^2))*rd*s^4), 
   "aN_SS" -> eps^4*(chi1*chi2*((3*(-1 + delta^4 - 16*nu^2))/8 + 
         (3*kap1*(-1 + delta^4 + 8*nu - 16*nu^2))/16 + 
         (3*kap2*(-1 + delta^4 + 8*nu - 16*nu^2))/16) + 
       chi2^2*((3*(-1 + 2*delta - 2*delta^3 + delta^4 + 8*nu - 8*delta*nu - 
            16*nu^2))/16 + (3*kap1*(-1 + 2*delta - 2*delta^3 + delta^4 + 
            8*nu - 8*delta*nu - 16*nu^2))/32 + 
         (3*kap2*(-9 + 10*delta - 2*delta^3 + delta^4 + 24*nu - 8*delta*nu - 
            16*nu^2))/32) + chi1^2*((3*(-1 - 2*delta + 2*delta^3 + delta^4 + 
            8*nu + 8*delta*nu - 16*nu^2))/16 + 
         (3*kap2*(-1 - 2*delta + 2*delta^3 + delta^4 + 8*nu + 8*delta*nu - 
            16*nu^2))/32 + (3*kap1*(-9 - 10*delta + 2*delta^3 + delta^4 + 
            24*nu + 8*delta*nu - 16*nu^2))/32))*s^4 + 
     eps^6*((chi1*chi2*((3*kap2*(1 + delta - 2*delta^3 - delta^4 + delta^5 - 
              14*nu - 4*delta*nu + 4*delta^3*nu + 6*delta^4*nu + 64*nu^2 - 
              96*nu^3))/32 + (3*(-4 + 4*delta^4 + 21*nu + 3*delta^4*nu - 
              64*nu^2 - 48*nu^3))/8 - (3*kap1*(-1 + delta - 2*delta^3 + 
              delta^4 + delta^5 + 14*nu - 4*delta*nu + 4*delta^3*nu - 
              6*delta^4*nu - 64*nu^2 + 96*nu^3))/32) + 
         chi1^2*((3*kap2*(-3 - 3*delta + 2*delta^3 + 3*delta^4 + delta^5 + 
              18*nu + 16*delta^3*nu + 6*delta^4*nu + 48*delta*nu^2 - 
              96*nu^3))/64 + (3*(-4 - 10*delta + 10*delta^3 + 4*delta^4 + 
              21*nu + 26*delta*nu + 6*delta^3*nu + 3*delta^4*nu - 40*nu^2 + 
              24*delta*nu^2 - 48*nu^3))/16 - 
           (3*kap1*(11 + 5*delta + 10*delta^3 + 5*delta^4 + delta^5 + 46*nu + 
              88*delta*nu - 8*delta^3*nu - 6*delta^4*nu - 224*nu^2 - 
              48*delta*nu^2 + 96*nu^3))/64) + 
         chi2^2*((3*kap2*(-11 + 5*delta + 10*delta^3 - 5*delta^4 + delta^5 - 
              46*nu + 88*delta*nu - 8*delta^3*nu + 6*delta^4*nu + 224*nu^2 - 
              48*delta*nu^2 - 96*nu^3))/64 + (3*(-4 + 10*delta - 10*delta^3 + 
              4*delta^4 + 21*nu - 26*delta*nu - 6*delta^3*nu + 3*delta^4*nu - 
              40*nu^2 - 24*delta*nu^2 - 48*nu^3))/16 - 
           (3*kap1*(3 - 3*delta + 2*delta^3 - 3*delta^4 + delta^5 - 18*nu + 
              16*delta^3*nu - 6*delta^4*nu + 48*delta*nu^2 + 96*nu^3))/64))*
        p^2*s^2 + (chi1*chi2*((3*(2 - 2*delta^4 - 5*nu + 5*delta^4*nu + 
              32*nu^2 - 80*nu^3))/16 + (3*kap1*(2*delta - 4*delta^3 + 
              2*delta^5 - 5*nu - 8*delta*nu + 8*delta^3*nu + 5*delta^4*nu + 
              40*nu^2 - 80*nu^3))/32 - (3*kap2*(2*delta - 4*delta^3 + 
              2*delta^5 + 5*nu - 8*delta*nu + 8*delta^3*nu - 5*delta^4*nu - 
              40*nu^2 + 80*nu^3))/32) + chi1^2*
          ((3*kap1*(40 + 30*delta + 16*delta^3 + 8*delta^4 + 2*delta^5 - 
              109*nu - 10*delta*nu + 18*delta^3*nu + 5*delta^4*nu - 8*nu^2 + 
              40*delta*nu^2 - 80*nu^3))/64 + (3*(2 + 4*delta - 4*delta^3 - 
              2*delta^4 - 21*nu - 26*delta*nu + 10*delta^3*nu + 
              5*delta^4*nu + 72*nu^2 + 40*delta*nu^2 - 80*nu^3))/32 - 
           (3*kap2*(-8 - 10*delta + 8*delta^3 + 8*delta^4 + 2*delta^5 + 
              69*nu + 50*delta*nu - 2*delta^3*nu - 5*delta^4*nu - 168*nu^2 - 
              40*delta*nu^2 + 80*nu^3))/64) + 
         chi2^2*((3*(2 - 4*delta + 4*delta^3 - 2*delta^4 - 21*nu + 
              26*delta*nu - 10*delta^3*nu + 5*delta^4*nu + 72*nu^2 - 
              40*delta*nu^2 - 80*nu^3))/32 + 
           (3*kap1*(8 - 10*delta + 8*delta^3 - 8*delta^4 + 2*delta^5 - 
              69*nu + 50*delta*nu - 2*delta^3*nu + 5*delta^4*nu + 168*nu^2 - 
              40*delta*nu^2 - 80*nu^3))/64 - 
           (3*kap2*(-40 + 30*delta + 16*delta^3 - 8*delta^4 + 2*delta^5 + 
              109*nu - 10*delta*nu + 18*delta^3*nu - 5*delta^4*nu + 8*nu^2 + 
              40*delta*nu^2 + 80*nu^3))/64))*rd^2*s^4 + 
       (chi1*chi2*((9 - 9*delta^4 + 5*nu - 5*delta^4*nu + 144*nu^2 + 80*nu^3)/
            4 + (kap1*(14 - 2*delta + 4*delta^3 - 14*delta^4 - 2*delta^5 - 
              107*nu + 8*delta*nu - 8*delta^3*nu - 5*delta^4*nu + 184*nu^2 + 
              80*nu^3))/8 + (kap2*(14 + 2*delta - 4*delta^3 - 14*delta^4 + 
              2*delta^5 - 107*nu - 8*delta*nu + 8*delta^3*nu - 5*delta^4*nu + 
              184*nu^2 + 80*nu^3))/8) + chi1^2*
          ((kap2*(6 + 18*delta - 20*delta^3 - 6*delta^4 + 2*delta^5 - 43*nu - 
              62*delta*nu - 2*delta^3*nu - 5*delta^4*nu + 56*nu^2 - 
              40*delta*nu^2 + 80*nu^3))/16 + (9 + 18*delta - 18*delta^3 - 
             9*delta^4 - 67*nu - 62*delta*nu - 10*delta^3*nu - 5*delta^4*nu + 
             104*nu^2 - 40*delta*nu^2 + 80*nu^3)/8 + 
           (kap1*(86 + 110*delta - 44*delta^3 - 22*delta^4 - 2*delta^5 - 
              227*nu - 102*delta*nu - 18*delta^3*nu - 5*delta^4*nu + 
              232*nu^2 - 40*delta*nu^2 + 80*nu^3))/16) + 
         chi2^2*((kap1*(6 - 18*delta + 20*delta^3 - 6*delta^4 - 2*delta^5 - 
              43*nu + 62*delta*nu + 2*delta^3*nu - 5*delta^4*nu + 56*nu^2 + 
              40*delta*nu^2 + 80*nu^3))/16 + (9 - 18*delta + 18*delta^3 - 
             9*delta^4 - 67*nu + 62*delta*nu + 10*delta^3*nu - 5*delta^4*nu + 
             104*nu^2 + 40*delta*nu^2 + 80*nu^3)/8 + 
           (kap2*(86 - 110*delta + 44*delta^3 - 22*delta^4 + 2*delta^5 - 
              227*nu + 102*delta*nu + 18*delta^3*nu - 5*delta^4*nu + 
              232*nu^2 + 40*delta*nu^2 + 80*nu^3))/16))*s^5), 
   "aLambda_SS" -> 
    eps^6*(chi1*chi2*((3*kap2*(7 + delta - 2*delta^3 - 7*delta^4 + delta^5 - 
           58*nu - 4*delta*nu + 4*delta^3*nu + 2*delta^4*nu + 128*nu^2 - 
           32*nu^3))/16 + (3*(-5 + 5*delta^4 + 47*nu + delta^4*nu - 80*nu^2 - 
           16*nu^3))/4 - (3*kap1*(-7 + delta - 2*delta^3 + 7*delta^4 + 
           delta^5 + 58*nu - 4*delta*nu + 4*delta^3*nu - 2*delta^4*nu - 
           128*nu^2 + 32*nu^3))/16) + 
      chi1^2*((3*kap2*(3 + 9*delta - 10*delta^3 - 3*delta^4 + delta^5 - 
           26*nu - 40*delta*nu + 8*delta^3*nu + 2*delta^4*nu + 64*nu^2 + 
           16*delta*nu^2 - 32*nu^3))/32 + 
        (3*(-5 - 14*delta + 14*delta^3 + 5*delta^4 + 23*nu + 38*delta*nu + 
           2*delta^3*nu + delta^4*nu - 72*nu^2 + 8*delta*nu^2 - 16*nu^3))/8 - 
        (3*kap1*(-43 - 55*delta + 22*delta^3 + 11*delta^4 + delta^5 + 
           154*nu + 96*delta*nu - 2*delta^4*nu - 224*nu^2 - 16*delta*nu^2 + 
           32*nu^3))/32) + chi2^2*
       ((3*kap2*(43 - 55*delta + 22*delta^3 - 11*delta^4 + delta^5 - 154*nu + 
           96*delta*nu + 2*delta^4*nu + 224*nu^2 - 16*delta*nu^2 - 32*nu^3))/
         32 + (3*(-5 + 14*delta - 14*delta^3 + 5*delta^4 + 23*nu - 
           38*delta*nu - 2*delta^3*nu + delta^4*nu - 72*nu^2 - 8*delta*nu^2 - 
           16*nu^3))/8 - (3*kap1*(-3 + 9*delta - 10*delta^3 + 3*delta^4 + 
           delta^5 + 26*nu - 40*delta*nu + 8*delta^3*nu - 2*delta^4*nu - 
           64*nu^2 + 16*delta*nu^2 + 32*nu^3))/32))*p*rd*s^3|>, 
 "acceleration" -> 
  <|"aN" -> -s^2 + eps^3*(chi2*(1 - delta + nu) + chi1*(1 + delta + nu))*p*
      s^2 + eps^2*((-1 - 3*nu)*p^2 + ((6 - 7*nu)*rd^2*s^2)/2 + 
       2*(2 + nu)*s^3) + eps^5*(((-5*chi2*(-nu + delta*nu))/2 + 
         (5*chi1*(nu + delta*nu))/2)*p^3 + 
       ((chi2*(-12 + 12*delta + 13*nu - delta*nu + 18*nu^2))/4 + 
         (chi1*(-12 - 12*delta + 13*nu + delta*nu + 18*nu^2))/4)*p*rd^2*s^2 + 
       ((chi1*(-8 - 8*delta - 13*nu - 5*delta*nu - 8*nu^2))/2 + 
         (chi2*(-8 + 8*delta - 13*nu + 5*delta*nu - 8*nu^2))/2)*p*s^3) + 
     eps^4*(2*(3*nu + 2*nu^2)*p^2*rd^2 + ((-3*nu + 4*nu^2)*p^4)/s^2 + 
       ((13*nu - 4*nu^2)*p^2*s)/2 + (21*(nu + nu^2)*rd^4*s^2)/8 + 
       (11*nu - 4*nu^2)*rd^2*s^3 + ((-3*(12 + 29*nu))/4 + 
         chi1*chi2*((3*(-1 + delta^4 - 16*nu^2))/8 + 
           (3*kap1*(-1 + delta^4 + 8*nu - 16*nu^2))/16 + 
           (3*kap2*(-1 + delta^4 + 8*nu - 16*nu^2))/16) + 
         chi2^2*((3*(-1 + 2*delta - 2*delta^3 + delta^4 + 8*nu - 8*delta*nu - 
              16*nu^2))/16 + (3*kap1*(-1 + 2*delta - 2*delta^3 + delta^4 + 
              8*nu - 8*delta*nu - 16*nu^2))/32 + 
           (3*kap2*(-9 + 10*delta - 2*delta^3 + delta^4 + 24*nu - 
              8*delta*nu - 16*nu^2))/32) + 
         chi1^2*((3*(-1 - 2*delta + 2*delta^3 + delta^4 + 8*nu + 8*delta*nu - 
              16*nu^2))/16 + (3*kap2*(-1 - 2*delta + 2*delta^3 + delta^4 + 
              8*nu + 8*delta*nu - 16*nu^2))/32 + 
           (3*kap1*(-9 - 10*delta + 2*delta^3 + delta^4 + 24*nu + 
              8*delta*nu - 16*nu^2))/32))*s^4) + 
     eps^6*(((28*nu + 8*nu^2 - 207*nu^3)*p^2*rd^4)/8 + 
       ((-11*nu + 49*nu^2 - 52*nu^3)*p^6)/(4*s^4) + 
       ((59*nu - 95*nu^2 - 180*nu^3)*p^4*rd^2)/(8*s^2) + 
       ((-75*nu - 32*nu^2 + 40*nu^3)*p^4)/(4*s) + 
       ((197*nu - 10*nu^2 + 20*nu^3)*p^2*rd^2*s)/2 + 
       (p^2*(chi1*chi2*((3*kap2*(1 + delta - 2*delta^3 - delta^4 + delta^5 - 
                14*nu - 4*delta*nu + 4*delta^3*nu + 6*delta^4*nu + 64*nu^2 - 
                96*nu^3))/32 + (3*(-4 + 4*delta^4 + 21*nu + 3*delta^4*nu - 
                64*nu^2 - 48*nu^3))/8 - (3*kap1*(-1 + delta - 2*delta^3 + 
                delta^4 + delta^5 + 14*nu - 4*delta*nu + 4*delta^3*nu - 
                6*delta^4*nu - 64*nu^2 + 96*nu^3))/32) + 
           chi1^2*((3*kap2*(-3 - 3*delta + 2*delta^3 + 3*delta^4 + delta^5 + 
                18*nu + 16*delta^3*nu + 6*delta^4*nu + 48*delta*nu^2 - 
                96*nu^3))/64 + (3*(-4 - 10*delta + 10*delta^3 + 4*delta^4 + 
                21*nu + 26*delta*nu + 6*delta^3*nu + 3*delta^4*nu - 40*nu^2 + 
                24*delta*nu^2 - 48*nu^3))/16 - (3*kap1*(11 + 5*delta + 
                10*delta^3 + 5*delta^4 + delta^5 + 46*nu + 88*delta*nu - 
                8*delta^3*nu - 6*delta^4*nu - 224*nu^2 - 48*delta*nu^2 + 
                96*nu^3))/64) + chi2^2*((3*kap2*(-11 + 5*delta + 10*delta^3 - 
                5*delta^4 + delta^5 - 46*nu + 88*delta*nu - 8*delta^3*nu + 
                6*delta^4*nu + 224*nu^2 - 48*delta*nu^2 - 96*nu^3))/64 + 
             (3*(-4 + 10*delta - 10*delta^3 + 4*delta^4 + 21*nu - 
                26*delta*nu - 6*delta^3*nu + 3*delta^4*nu - 40*nu^2 - 
                24*delta*nu^2 - 48*nu^3))/16 - (3*kap1*(3 - 3*delta + 
                2*delta^3 - 3*delta^4 + delta^5 - 18*nu + 16*delta^3*nu - 
                6*delta^4*nu + 48*delta*nu^2 + 96*nu^3))/64) + 
           (166616*nu - 6720*nu^3 + 12915*nu*Pi^2)/6720) + 
         ((19*nu - 13*nu^2 - 147*nu^3)*rd^6)/16)*s^2 + 
       ((-199*nu + 96*nu^2 + 144*nu^3)*rd^4*s^3)/12 + 
       (chi1*chi2*((3*(2 - 2*delta^4 - 5*nu + 5*delta^4*nu + 32*nu^2 - 
              80*nu^3))/16 + (3*kap1*(2*delta - 4*delta^3 + 2*delta^5 - 
              5*nu - 8*delta*nu + 8*delta^3*nu + 5*delta^4*nu + 40*nu^2 - 
              80*nu^3))/32 - (3*kap2*(2*delta - 4*delta^3 + 2*delta^5 + 
              5*nu - 8*delta*nu + 8*delta^3*nu - 5*delta^4*nu - 40*nu^2 + 
              80*nu^3))/32) + chi1^2*((3*kap1*(40 + 30*delta + 16*delta^3 + 
              8*delta^4 + 2*delta^5 - 109*nu - 10*delta*nu + 18*delta^3*nu + 
              5*delta^4*nu - 8*nu^2 + 40*delta*nu^2 - 80*nu^3))/64 + 
           (3*(2 + 4*delta - 4*delta^3 - 2*delta^4 - 21*nu - 26*delta*nu + 
              10*delta^3*nu + 5*delta^4*nu + 72*nu^2 + 40*delta*nu^2 - 
              80*nu^3))/32 - (3*kap2*(-8 - 10*delta + 8*delta^3 + 8*delta^4 + 
              2*delta^5 + 69*nu + 50*delta*nu - 2*delta^3*nu - 5*delta^4*nu - 
              168*nu^2 - 40*delta*nu^2 + 80*nu^3))/64) + 
         chi2^2*((3*(2 - 4*delta + 4*delta^3 - 2*delta^4 - 21*nu + 
              26*delta*nu - 10*delta^3*nu + 5*delta^4*nu + 72*nu^2 - 
              40*delta*nu^2 - 80*nu^3))/32 + 
           (3*kap1*(8 - 10*delta + 8*delta^3 - 8*delta^4 + 2*delta^5 - 
              69*nu + 50*delta*nu - 2*delta^3*nu + 5*delta^4*nu + 168*nu^2 - 
              40*delta*nu^2 - 80*nu^3))/64 - 
           (3*kap2*(-40 + 30*delta + 16*delta^3 - 8*delta^4 + 2*delta^5 + 
              109*nu - 10*delta*nu + 18*delta^3*nu - 5*delta^4*nu + 8*nu^2 + 
              40*delta*nu^2 + 80*nu^3))/64) + (10080 - 347636*nu - 
           88620*nu^2 - 6720*nu^3 - 12915*nu*Pi^2)/3360)*rd^2*s^4 + 
       (chi1*chi2*((9 - 9*delta^4 + 5*nu - 5*delta^4*nu + 144*nu^2 + 80*nu^3)/
            4 + (kap1*(14 - 2*delta + 4*delta^3 - 14*delta^4 - 2*delta^5 - 
              107*nu + 8*delta*nu - 8*delta^3*nu - 5*delta^4*nu + 184*nu^2 + 
              80*nu^3))/8 + (kap2*(14 + 2*delta - 4*delta^3 - 14*delta^4 + 
              2*delta^5 - 107*nu - 8*delta*nu + 8*delta^3*nu - 5*delta^4*nu + 
              184*nu^2 + 80*nu^3))/8) + chi1^2*
          ((kap2*(6 + 18*delta - 20*delta^3 - 6*delta^4 + 2*delta^5 - 43*nu - 
              62*delta*nu - 2*delta^3*nu - 5*delta^4*nu + 56*nu^2 - 
              40*delta*nu^2 + 80*nu^3))/16 + (9 + 18*delta - 18*delta^3 - 
             9*delta^4 - 67*nu - 62*delta*nu - 10*delta^3*nu - 5*delta^4*nu + 
             104*nu^2 - 40*delta*nu^2 + 80*nu^3)/8 + 
           (kap1*(86 + 110*delta - 44*delta^3 - 22*delta^4 - 2*delta^5 - 
              227*nu - 102*delta*nu - 18*delta^3*nu - 5*delta^4*nu + 
              232*nu^2 - 40*delta*nu^2 + 80*nu^3))/16) + 
         chi2^2*((kap1*(6 - 18*delta + 20*delta^3 - 6*delta^4 - 2*delta^5 - 
              43*nu + 62*delta*nu + 2*delta^3*nu - 5*delta^4*nu + 56*nu^2 + 
              40*delta*nu^2 + 80*nu^3))/16 + (9 - 18*delta + 18*delta^3 - 
             9*delta^4 - 67*nu + 62*delta*nu + 10*delta^3*nu - 5*delta^4*nu + 
             104*nu^2 + 40*delta*nu^2 + 80*nu^3)/8 + 
           (kap2*(86 - 110*delta + 44*delta^3 - 22*delta^4 + 2*delta^5 - 
              227*nu + 102*delta*nu + 18*delta^3*nu - 5*delta^4*nu + 
              232*nu^2 + 40*delta*nu^2 + 80*nu^3))/16) + 
         (768 + 5596*nu + 1704*nu^2 - 123*nu*Pi^2)/48)*s^5), 
   "aLambda" -> -2*eps^2*(-2 + nu)*p*rd*s + 
     eps^3*(chi1*(-1 - delta + 2*nu) + chi2*(-1 + delta + 2*nu))*rd*s^3 + 
     eps^4*(((15*nu + 4*nu^2)*p^3*rd)/(2*s) + (3*nu - nu^2)*p*rd^3*s + 
       ((-4 - 41*nu - 8*nu^2)*p*rd*s^2)/2) + 
     eps^6*((15*nu + 27*nu^2 + 10*nu^3)*p^3*rd + 
       ((65*nu - 152*nu^2 - 48*nu^3)*p^5*rd)/(8*s^3) + 
       ((17*nu - 41*nu^2)*p^3*rd^3)/(4*s) + ((7*nu - 25*nu^2 + 9*nu^3)*p*rd^5*
         s)/4 + ((-239*nu - 15*nu^2 - 48*nu^3)*p*rd^3*s^2)/6 + 
       p*(chi1*chi2*((3*kap2*(7 + delta - 2*delta^3 - 7*delta^4 + delta^5 - 
              58*nu - 4*delta*nu + 4*delta^3*nu + 2*delta^4*nu + 128*nu^2 - 
              32*nu^3))/16 + (3*(-5 + 5*delta^4 + 47*nu + delta^4*nu - 
              80*nu^2 - 16*nu^3))/4 - (3*kap1*(-7 + delta - 2*delta^3 + 
              7*delta^4 + delta^5 + 58*nu - 4*delta*nu + 4*delta^3*nu - 
              2*delta^4*nu - 128*nu^2 + 32*nu^3))/16) + 
         chi1^2*((3*kap2*(3 + 9*delta - 10*delta^3 - 3*delta^4 + delta^5 - 
              26*nu - 40*delta*nu + 8*delta^3*nu + 2*delta^4*nu + 64*nu^2 + 
              16*delta*nu^2 - 32*nu^3))/32 + (3*(-5 - 14*delta + 14*delta^3 + 
              5*delta^4 + 23*nu + 38*delta*nu + 2*delta^3*nu + delta^4*nu - 
              72*nu^2 + 8*delta*nu^2 - 16*nu^3))/8 - 
           (3*kap1*(-43 - 55*delta + 22*delta^3 + 11*delta^4 + delta^5 + 
              154*nu + 96*delta*nu - 2*delta^4*nu - 224*nu^2 - 
              16*delta*nu^2 + 32*nu^3))/32) + 
         chi2^2*((3*kap2*(43 - 55*delta + 22*delta^3 - 11*delta^4 + delta^5 - 
              154*nu + 96*delta*nu + 2*delta^4*nu + 224*nu^2 - 
              16*delta*nu^2 - 32*nu^3))/32 + (3*(-5 + 14*delta - 14*delta^3 + 
              5*delta^4 + 23*nu - 38*delta*nu - 2*delta^3*nu + delta^4*nu - 
              72*nu^2 - 8*delta*nu^2 - 16*nu^3))/8 - 
           (3*kap1*(-3 + 9*delta - 10*delta^3 + 3*delta^4 + delta^5 + 26*nu - 
              40*delta*nu + 8*delta^3*nu - 2*delta^4*nu - 64*nu^2 + 
              16*delta*nu^2 + 32*nu^3))/32) + 
         (13440 + 23396*nu - 84000*nu^2 - 26880*nu^3 + 12915*nu*Pi^2)/3360)*
        rd*s^3) + eps^5*(((chi2*(-6 + 6*delta + 7*nu - delta*nu))/2 + 
         (chi1*(-6 - 6*delta + 7*nu + delta*nu))/2)*p^2*rd*s + 
       (chi1*(-nu - delta*nu + 3*nu^2) + chi2*(-nu + delta*nu + 3*nu^2))*rd^3*
        s^3 + (-2*chi2*(-1 + delta + nu + delta*nu - nu^2) + 
         2*chi1*(1 + delta - nu + delta*nu + nu^2))*rd*s^4)|>, 
 "polarODE" -> <|"rddot" -> p^2/s - s^2 + 
     eps^3*(chi2*(1 - delta + nu) + chi1*(1 + delta + nu))*p*s^2 + 
     eps^2*((-1 - 3*nu)*p^2 + ((6 - 7*nu)*rd^2*s^2)/2 + 2*(2 + nu)*s^3) + 
     eps^5*(((-5*chi2*(-nu + delta*nu))/2 + (5*chi1*(nu + delta*nu))/2)*p^3 + 
       ((chi2*(-12 + 12*delta + 13*nu - delta*nu + 18*nu^2))/4 + 
         (chi1*(-12 - 12*delta + 13*nu + delta*nu + 18*nu^2))/4)*p*rd^2*s^2 + 
       ((chi1*(-8 - 8*delta - 13*nu - 5*delta*nu - 8*nu^2))/2 + 
         (chi2*(-8 + 8*delta - 13*nu + 5*delta*nu - 8*nu^2))/2)*p*s^3) + 
     eps^4*(2*(3*nu + 2*nu^2)*p^2*rd^2 + ((-3*nu + 4*nu^2)*p^4)/s^2 + 
       ((13*nu - 4*nu^2)*p^2*s)/2 + (21*(nu + nu^2)*rd^4*s^2)/8 + 
       (11*nu - 4*nu^2)*rd^2*s^3 + ((-3*(12 + 29*nu))/4 + 
         chi1*chi2*((3*(-1 + delta^4 - 16*nu^2))/8 + 
           (3*kap1*(-1 + delta^4 + 8*nu - 16*nu^2))/16 + 
           (3*kap2*(-1 + delta^4 + 8*nu - 16*nu^2))/16) + 
         chi2^2*((3*(-1 + 2*delta - 2*delta^3 + delta^4 + 8*nu - 8*delta*nu - 
              16*nu^2))/16 + (3*kap1*(-1 + 2*delta - 2*delta^3 + delta^4 + 
              8*nu - 8*delta*nu - 16*nu^2))/32 + 
           (3*kap2*(-9 + 10*delta - 2*delta^3 + delta^4 + 24*nu - 
              8*delta*nu - 16*nu^2))/32) + 
         chi1^2*((3*(-1 - 2*delta + 2*delta^3 + delta^4 + 8*nu + 8*delta*nu - 
              16*nu^2))/16 + (3*kap2*(-1 - 2*delta + 2*delta^3 + delta^4 + 
              8*nu + 8*delta*nu - 16*nu^2))/32 + 
           (3*kap1*(-9 - 10*delta + 2*delta^3 + delta^4 + 24*nu + 
              8*delta*nu - 16*nu^2))/32))*s^4) + 
     eps^6*(((28*nu + 8*nu^2 - 207*nu^3)*p^2*rd^4)/8 + 
       ((-11*nu + 49*nu^2 - 52*nu^3)*p^6)/(4*s^4) + 
       ((59*nu - 95*nu^2 - 180*nu^3)*p^4*rd^2)/(8*s^2) + 
       ((-75*nu - 32*nu^2 + 40*nu^3)*p^4)/(4*s) + 
       ((197*nu - 10*nu^2 + 20*nu^3)*p^2*rd^2*s)/2 + 
       (p^2*(chi1*chi2*((3*kap2*(1 + delta - 2*delta^3 - delta^4 + delta^5 - 
                14*nu - 4*delta*nu + 4*delta^3*nu + 6*delta^4*nu + 64*nu^2 - 
                96*nu^3))/32 + (3*(-4 + 4*delta^4 + 21*nu + 3*delta^4*nu - 
                64*nu^2 - 48*nu^3))/8 - (3*kap1*(-1 + delta - 2*delta^3 + 
                delta^4 + delta^5 + 14*nu - 4*delta*nu + 4*delta^3*nu - 
                6*delta^4*nu - 64*nu^2 + 96*nu^3))/32) + 
           chi1^2*((3*kap2*(-3 - 3*delta + 2*delta^3 + 3*delta^4 + delta^5 + 
                18*nu + 16*delta^3*nu + 6*delta^4*nu + 48*delta*nu^2 - 
                96*nu^3))/64 + (3*(-4 - 10*delta + 10*delta^3 + 4*delta^4 + 
                21*nu + 26*delta*nu + 6*delta^3*nu + 3*delta^4*nu - 40*nu^2 + 
                24*delta*nu^2 - 48*nu^3))/16 - (3*kap1*(11 + 5*delta + 
                10*delta^3 + 5*delta^4 + delta^5 + 46*nu + 88*delta*nu - 
                8*delta^3*nu - 6*delta^4*nu - 224*nu^2 - 48*delta*nu^2 + 
                96*nu^3))/64) + chi2^2*((3*kap2*(-11 + 5*delta + 10*delta^3 - 
                5*delta^4 + delta^5 - 46*nu + 88*delta*nu - 8*delta^3*nu + 
                6*delta^4*nu + 224*nu^2 - 48*delta*nu^2 - 96*nu^3))/64 + 
             (3*(-4 + 10*delta - 10*delta^3 + 4*delta^4 + 21*nu - 
                26*delta*nu - 6*delta^3*nu + 3*delta^4*nu - 40*nu^2 - 
                24*delta*nu^2 - 48*nu^3))/16 - (3*kap1*(3 - 3*delta + 
                2*delta^3 - 3*delta^4 + delta^5 - 18*nu + 16*delta^3*nu - 
                6*delta^4*nu + 48*delta*nu^2 + 96*nu^3))/64) + 
           (166616*nu - 6720*nu^3 + 12915*nu*Pi^2)/6720) + 
         ((19*nu - 13*nu^2 - 147*nu^3)*rd^6)/16)*s^2 + 
       ((-199*nu + 96*nu^2 + 144*nu^3)*rd^4*s^3)/12 + 
       (chi1*chi2*((3*(2 - 2*delta^4 - 5*nu + 5*delta^4*nu + 32*nu^2 - 
              80*nu^3))/16 + (3*kap1*(2*delta - 4*delta^3 + 2*delta^5 - 
              5*nu - 8*delta*nu + 8*delta^3*nu + 5*delta^4*nu + 40*nu^2 - 
              80*nu^3))/32 - (3*kap2*(2*delta - 4*delta^3 + 2*delta^5 + 
              5*nu - 8*delta*nu + 8*delta^3*nu - 5*delta^4*nu - 40*nu^2 + 
              80*nu^3))/32) + chi1^2*((3*kap1*(40 + 30*delta + 16*delta^3 + 
              8*delta^4 + 2*delta^5 - 109*nu - 10*delta*nu + 18*delta^3*nu + 
              5*delta^4*nu - 8*nu^2 + 40*delta*nu^2 - 80*nu^3))/64 + 
           (3*(2 + 4*delta - 4*delta^3 - 2*delta^4 - 21*nu - 26*delta*nu + 
              10*delta^3*nu + 5*delta^4*nu + 72*nu^2 + 40*delta*nu^2 - 
              80*nu^3))/32 - (3*kap2*(-8 - 10*delta + 8*delta^3 + 8*delta^4 + 
              2*delta^5 + 69*nu + 50*delta*nu - 2*delta^3*nu - 5*delta^4*nu - 
              168*nu^2 - 40*delta*nu^2 + 80*nu^3))/64) + 
         chi2^2*((3*(2 - 4*delta + 4*delta^3 - 2*delta^4 - 21*nu + 
              26*delta*nu - 10*delta^3*nu + 5*delta^4*nu + 72*nu^2 - 
              40*delta*nu^2 - 80*nu^3))/32 + 
           (3*kap1*(8 - 10*delta + 8*delta^3 - 8*delta^4 + 2*delta^5 - 
              69*nu + 50*delta*nu - 2*delta^3*nu + 5*delta^4*nu + 168*nu^2 - 
              40*delta*nu^2 - 80*nu^3))/64 - 
           (3*kap2*(-40 + 30*delta + 16*delta^3 - 8*delta^4 + 2*delta^5 + 
              109*nu - 10*delta*nu + 18*delta^3*nu - 5*delta^4*nu + 8*nu^2 + 
              40*delta*nu^2 + 80*nu^3))/64) + (10080 - 347636*nu - 
           88620*nu^2 - 6720*nu^3 - 12915*nu*Pi^2)/3360)*rd^2*s^4 + 
       (chi1*chi2*((9 - 9*delta^4 + 5*nu - 5*delta^4*nu + 144*nu^2 + 80*nu^3)/
            4 + (kap1*(14 - 2*delta + 4*delta^3 - 14*delta^4 - 2*delta^5 - 
              107*nu + 8*delta*nu - 8*delta^3*nu - 5*delta^4*nu + 184*nu^2 + 
              80*nu^3))/8 + (kap2*(14 + 2*delta - 4*delta^3 - 14*delta^4 + 
              2*delta^5 - 107*nu - 8*delta*nu + 8*delta^3*nu - 5*delta^4*nu + 
              184*nu^2 + 80*nu^3))/8) + chi1^2*
          ((kap2*(6 + 18*delta - 20*delta^3 - 6*delta^4 + 2*delta^5 - 43*nu - 
              62*delta*nu - 2*delta^3*nu - 5*delta^4*nu + 56*nu^2 - 
              40*delta*nu^2 + 80*nu^3))/16 + (9 + 18*delta - 18*delta^3 - 
             9*delta^4 - 67*nu - 62*delta*nu - 10*delta^3*nu - 5*delta^4*nu + 
             104*nu^2 - 40*delta*nu^2 + 80*nu^3)/8 + 
           (kap1*(86 + 110*delta - 44*delta^3 - 22*delta^4 - 2*delta^5 - 
              227*nu - 102*delta*nu - 18*delta^3*nu - 5*delta^4*nu + 
              232*nu^2 - 40*delta*nu^2 + 80*nu^3))/16) + 
         chi2^2*((kap1*(6 - 18*delta + 20*delta^3 - 6*delta^4 - 2*delta^5 - 
              43*nu + 62*delta*nu + 2*delta^3*nu - 5*delta^4*nu + 56*nu^2 + 
              40*delta*nu^2 + 80*nu^3))/16 + (9 - 18*delta + 18*delta^3 - 
             9*delta^4 - 67*nu + 62*delta*nu + 10*delta^3*nu - 5*delta^4*nu + 
             104*nu^2 + 40*delta*nu^2 + 80*nu^3)/8 + 
           (kap2*(86 - 110*delta + 44*delta^3 - 22*delta^4 + 2*delta^5 - 
              227*nu + 102*delta*nu + 18*delta^3*nu - 5*delta^4*nu + 
              232*nu^2 + 40*delta*nu^2 + 80*nu^3))/16) + 
         (768 + 5596*nu + 1704*nu^2 - 123*nu*Pi^2)/48)*s^5), 
   "phiddot" -> -2*p*rd*s - 2*eps^2*(-2 + nu)*p*rd*s^2 + 
     eps^3*(chi1*(-1 - delta + 2*nu) + chi2*(-1 + delta + 2*nu))*rd*s^4 + 
     eps^4*(((15*nu + 4*nu^2)*p^3*rd)/2 + (3*nu - nu^2)*p*rd^3*s^2 + 
       ((-4 - 41*nu - 8*nu^2)*p*rd*s^3)/2) + 
     eps^6*(((17*nu - 41*nu^2)*p^3*rd^3)/4 + 
       ((65*nu - 152*nu^2 - 48*nu^3)*p^5*rd)/(8*s^2) + 
       (15*nu + 27*nu^2 + 10*nu^3)*p^3*rd*s + 
       ((7*nu - 25*nu^2 + 9*nu^3)*p*rd^5*s^2)/4 + 
       ((-239*nu - 15*nu^2 - 48*nu^3)*p*rd^3*s^3)/6 + 
       p*(chi1*chi2*((3*kap2*(7 + delta - 2*delta^3 - 7*delta^4 + delta^5 - 
              58*nu - 4*delta*nu + 4*delta^3*nu + 2*delta^4*nu + 128*nu^2 - 
              32*nu^3))/16 + (3*(-5 + 5*delta^4 + 47*nu + delta^4*nu - 
              80*nu^2 - 16*nu^3))/4 - (3*kap1*(-7 + delta - 2*delta^3 + 
              7*delta^4 + delta^5 + 58*nu - 4*delta*nu + 4*delta^3*nu - 
              2*delta^4*nu - 128*nu^2 + 32*nu^3))/16) + 
         chi1^2*((3*kap2*(3 + 9*delta - 10*delta^3 - 3*delta^4 + delta^5 - 
              26*nu - 40*delta*nu + 8*delta^3*nu + 2*delta^4*nu + 64*nu^2 + 
              16*delta*nu^2 - 32*nu^3))/32 + (3*(-5 - 14*delta + 14*delta^3 + 
              5*delta^4 + 23*nu + 38*delta*nu + 2*delta^3*nu + delta^4*nu - 
              72*nu^2 + 8*delta*nu^2 - 16*nu^3))/8 - 
           (3*kap1*(-43 - 55*delta + 22*delta^3 + 11*delta^4 + delta^5 + 
              154*nu + 96*delta*nu - 2*delta^4*nu - 224*nu^2 - 
              16*delta*nu^2 + 32*nu^3))/32) + 
         chi2^2*((3*kap2*(43 - 55*delta + 22*delta^3 - 11*delta^4 + delta^5 - 
              154*nu + 96*delta*nu + 2*delta^4*nu + 224*nu^2 - 
              16*delta*nu^2 - 32*nu^3))/32 + (3*(-5 + 14*delta - 14*delta^3 + 
              5*delta^4 + 23*nu - 38*delta*nu - 2*delta^3*nu + delta^4*nu - 
              72*nu^2 - 8*delta*nu^2 - 16*nu^3))/8 - 
           (3*kap1*(-3 + 9*delta - 10*delta^3 + 3*delta^4 + delta^5 + 26*nu - 
              40*delta*nu + 8*delta^3*nu - 2*delta^4*nu - 64*nu^2 + 
              16*delta*nu^2 + 32*nu^3))/32) + 
         (13440 + 23396*nu - 84000*nu^2 - 26880*nu^3 + 12915*nu*Pi^2)/3360)*
        rd*s^4) + eps^5*(((chi2*(-6 + 6*delta + 7*nu - delta*nu))/2 + 
         (chi1*(-6 - 6*delta + 7*nu + delta*nu))/2)*p^2*rd*s^2 + 
       (chi1*(-nu - delta*nu + 3*nu^2) + chi2*(-nu + delta*nu + 3*nu^2))*rd^3*
        s^4 + (-2*chi2*(-1 + delta + nu + delta*nu - nu^2) + 
         2*chi1*(1 + delta - nu + delta*nu + nu^2))*rd*s^5)|>|>
