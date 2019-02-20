L1 = 1.5;
L2 = 1.4;
L3 = 1.3;
L4 = 1.2;
L5 = 1;

theta_A = 10;
theta_B = 80;
theta_C = 185;

P_BA = [0;0;0];
P_CA = [0;0;0];

P_FB = [L1;0;0];

P_DC = [L2;0;0];

P_TF = [L5;
        0;
        0];

Lm = sqrt( L1^2 + L2^2 - 2*L1*L2*cosd(theta_C-theta_B));



phi = acosd((L3^2 - Lm^2 - L4^2)/(-2*Lm*L4));
psi = acosd((L2^2 - Lm^2 - L1^2)/(-2*Lm*L1));

theta_F = -(phi + psi);
  
%--

C_FB = rotz(theta_F);
C_BA = rotz(theta_B);

P_FA = P_BA + C_BA*P_FB;

P_TB = P_FB + C_FB*P_TF;
P_TA = P_BA + C_BA*P_TB;

C_AO = roty(theta_A);
P_AO = [0;0;0];

P_TO = P_AO + C_AO*P_TA

%--

V_TO = dP_TO + w_






