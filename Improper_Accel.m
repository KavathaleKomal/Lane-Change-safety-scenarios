%% Clean workspace and close all
clear all
close all
clc
%% Constraint for parameter


AVlongdecNO=-2;
G=0;
v=0;
d1=1;
d2=0.25;
TD=d1+d2;
AVlongaccmax=4;
AVlongdecEB=-7;
SignF=-1;
s=TD-d2;  
%% TTC calculation
TTC=(-v+sqrt(v^2+(2*AVlongaccmax*s)))/AVlongaccmax;

 %% FHTI calculation
  for j = 0.01 : 0.01 : TTC
    Dist_A =v*j+ 0.5 * AVlongaccmax * j^2;
    VV = v+AVlongaccmax*j;
    Dist_B = abs(VV*VV/(2*AVlongdecEB));
    if sign(((Dist_A + Dist_B) - s)) ~= sign(SignF)
        break;
    else
        signF = sign(((Dist_A + Dist_B) - s));
    end
  end
FHTI=j;