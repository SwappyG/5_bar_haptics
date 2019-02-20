sys = tf([607.6], [1 3.1309 607.6]);

[A, B, C, D] = tf2ss([607.6], [1 3.1309 607.6]);

A_aug = [A, [0;0]; C , 0];
B_aug = [B; 0];

K = place(A_aug, B_aug, [-100, -101, -1002]);
K1 = K(1:2);
K2 = K(3);


F = place(A', C', [-105, -106]);
F = F';



tic
x_hat = [0.1; .1];
x = [0; 0];
u = 0;
y = 0;

G = 10;
y_ref = 1;
accum = 0;
last_toc = toc;
while (toc < 2)
    
    delta_t = toc-last_toc;
    last_toc = toc;
    
    x_hat_dot = (A-F*C)*x_hat(:,end) + B*u(end) + F*y(end);
    x_hat(:,end+1) = x_hat(:,end) + x_hat_dot * delta_t;
    
    accum = accum + (y_ref-y(end))*delta_t;
    
    u(end+1) = -K1*x_hat(:,end) + K2*accum;
    
    x_dot = A*x(:,end) + B*u(end);
    x(:,end+1) = x(:,end) + x_dot * delta_t;
    
    y(end+1) = C*x(:,end);
    
end

clf
plot(x_hat(1,:))
hold on
plot(x_hat(2,:))
plot(x(1,:))
plot(x(2,:))
plot(y)
hold off
