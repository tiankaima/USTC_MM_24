import numpy as np
import matplotlib.pyplot as plt

# Parameters
alpha = 0.002
mu = 0.002
beta = 0.05
gamma = 0.3
S0 = 0.99

# Time grid
total_time = 100
sep = 10000
h = total_time / sep

# Initial condition
st = np.zeros((sep, 3)) # S, I, R
st[0, 0] = S0
st[0, 1] = 1 - S0
st[0, 2] = 0

# Euler method
for i in range(1, sep):
    st[i, 0] = st[i-1, 0] + h * (-beta * st[i-1, 0] * st[i-1, 1] + alpha * st[i-1, 2] - mu * st[i-1, 0])
    st[i, 1] = st[i-1, 1] + h * (beta * st[i-1, 0] * st[i-1, 1] - gamma * st[i-1, 1])
    st[i, 2] = st[i-1, 2] + h * gamma * st[i-1, 1]

# Plot
plt.plot(st[:, 0], label='S')
plt.plot(st[:, 1], label='I')
plt.plot(st[:, 2], label='R')

plt.xlabel('Time')
plt.ylabel('Proportion')
plt.legend()
# plt.show()

# Save
plt.savefig(f'./output/SIR_euler_{alpha}_{mu}_{beta}_{gamma}_{S0}.png')
