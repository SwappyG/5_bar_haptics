sys = tf([1], [1 4 0]);
ctrl = 33;

fdbk = minreal(sys*ctrl/(1+sys*ctrl))