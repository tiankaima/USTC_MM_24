import numpy as np
import matplotlib.pyplot as plt

# Parameters
alpha = 0.002
beta = 0.5
gamma = 0.3
mu = 0.002
sigma = 0.2
S0 = 0.99

total_time = 200
sep = 10000
h = total_time / sep

# Initial condition
st = np.zeros((sep, 4))  # S, E, I, R
st[0, 0] = S0
st[0, 1] = 0
st[0, 2] = 1 - S0
st[0, 3] = 0

# Euler method
for i in range(1, sep):
    st[i, 0] = st[i - 1, 0] + h * (
        -beta * st[i - 1, 0] * st[i - 1, 2] + alpha * st[i - 1, 0] - mu * st[i - 1, 0]
    )
    st[i, 1] = st[i - 1, 1] + h * (
        beta * st[i - 1, 0] * st[i - 1, 2] - sigma * st[i - 1, 1] - mu * st[i - 1, 1]
    )
    st[i, 2] = st[i - 1, 2] + h * (
        sigma * st[i - 1, 1] - gamma * st[i - 1, 2] - mu * st[i - 1, 2]
    )
    st[i, 3] = st[i - 1, 3] + h * (gamma * st[i - 1, 2] - mu * st[i - 1, 3])

# Plot
plt.plot(st[:, 0], label="S")
plt.plot(st[:, 1], label="E")
plt.plot(st[:, 2], label="I")
plt.plot(st[:, 3], label="R")

plt.xlabel("Time")
plt.ylabel("Proportion")
plt.legend()
# plt.show()

# Save
plt.savefig(f"./output/SEIR_euler_{alpha}_{mu}_{beta}_{gamma}_{sigma}_{S0}.png")
