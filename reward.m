function r=reward(a,b,t)
k = (-1) * abs(b - a);
BETA=0.3;
r = t*exp(k * BETA);