clc
clear all
close all

casestudy = case33bw;
re = runpf(casestudy);

vol = re.bus(:, 8);
Q = zeros(33, 61);

actions = [0.25:0.05:3.25];
epsilon = 0.5;
alpha = 0.1;
gamma = 0.1;

first_bus_number = randi(33);
bus_number = first_bus_number;

for episode = 1:6000
    
    num_action = epsilon_greedy(Q, bus_number, epsilon);
    casestudy.bus(bus_number, 3) = casestudy.bus(bus_number, 3) - actions(num_action);
    re = runpf(casestudy);
    ploss = sum(re.branch(:, 14) + re.branch(:, 16));
    g = 0;
    
    for j = 1:33
        if re.bus(j, 8) > 1.1 || re.bus(j, 8) < 0.9
            g = 1;
            break
        end
    end
    
    switch g
        case 1
            reward = -2;
        otherwise
            reward = -ploss;
    end
    
    next_bus_number = randi(33);
    [Q] = update_Q_learning(Q, bus_number, next_bus_number, num_action, reward, alpha, gamma);
    bus_number = next_bus_number;
    casestudy = case33bw;
    epsilon = epsilon*0.9999;
end
