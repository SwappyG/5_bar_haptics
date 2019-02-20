%#ok<*DEFNU>

s = tf('s');

P = tf([4],[1 4 4])

%% PID

% PID Constants
Kp = 5;
Kd = 1;
Ki = 4;
Kd_filter = 1/1000;

% PID Controller
C_pid = tf(pid(Kp, Ki, Kd));

%% State Space

% Convert plant to state space
P_ss = ss(P);

% Augment the A and B matrices for regulator
A_aug = [P_ss.A, zeros(length(P_ss.A), 1);
         P_ss.C, zeros(size(P_ss.C, 1), 1)];
B_aug = [P_ss.B;
         zeros(size(P_ss.C, 1), 1)];

% Use pole placement to determine K1 and K2     
K = place(A_aug, B_aug, [-10,-11,-12]);
K1 = K(1:length(P_ss.A));
K2 = K(length(P_ss.A)+1:end);

% Grab the A,B,C,D matrices
A = P_ss.A;
B = P_ss.B;
C = P_ss.C;
D = P_ss.D;

% Initialize state vectors
x = zeros(length(A),1);
u = 0;
e = 0;
y_ref = 1;
y = 0;

% Set the first order approximation resolution
dt = 0.001;

% Initialize state history vector buffers
u_hist = u;
x_hist = x;
y_hist = y;
e_hist = e;
t_hist = 0;

% Run for fixed number of steps
for index = 1:5000
    
    % get the next state vector
    dx = (A*x + B*u);
    x = dx*dt + x;
    
    % get the next output
    y = C*x + D*u;
    
    % determine error and get next input
    e = e + K2*(y_ref-y)*dt;
    u = e - K1*x;
    
    % store everything in the history buffers
    u_hist(end+1) = u;
    t_hist(end+1) = index*dt;
    x_hist(:,end+1) = x;
    y_hist(end+1) = y;
    e_hist(end+1) = e;
    
end

%% Plotting

% Plot the step input with PID Feedback
figure(1)
fdbk_pid = feedback(P*C_pid, 1);
step(fdbk_pid);

hold on

% Plot the step input of state feedback with regulator
plot(t_hist, y_hist, '--')
ylim([0 1.2])
hold off

% Plot the controller effort
figure(2)
plot(t_hist, u_hist)

