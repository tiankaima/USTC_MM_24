import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import scipy

df = pd.read_csv("./data/WHO-COVID-19-global-data.csv")

# Parameters
alpha = 0.002
beta = 0.5
gamma = 0.09
mu = 0.002
sigma = 0.14
sigma_I = 0.03
S0 = 0.99

total_time = 100
sep = 10000
h = total_time / sep

# Initial condition
st = np.zeros((sep, 6))  # S, E, I, R, K, D
st[0, 0] = S0
st[0, 1] = 0
st[0, 2] = 1 - S0
st[0, 3] = 0
st[0, 4] = 0
st[0, 5] = 0

# Euler method
for i in range(1, sep):
    st[i, 0] = st[i - 1, 0] + h * (
        -beta * st[i - 1, 0] * st[i - 1, 2] + alpha * st[i - 1, 0] - mu * st[i - 1, 0]
    )
    st[i, 1] = st[i - 1, 1] + h * (
        beta * st[i - 1, 0] * st[i - 1, 2] - sigma * st[i - 1, 1] - mu * st[i - 1, 1]
    )
    st[i, 2] = st[i - 1, 2] + h * (
        sigma * st[i - 1, 1] - (gamma + sigma_I) * st[i - 1, 2] - mu * st[i - 1, 2]
    )
    st[i, 3] = st[i - 1, 3] + h * (gamma * st[i - 1, 2] - mu * st[i - 1, 3])
    st[i, 4] = st[i - 1, 4] + h * (sigma * st[i - 1, 1])
    st[i, 5] = st[i - 1, 5] + h * (sigma_I * st[i - 1, 2])

df_cn = df[df["Country"] == "China"]
df_cn = df_cn[df_cn["Date_reported"] < "2020-04-10"]

fig, ax1 = plt.subplots()
ax2 = ax1.twinx()

realK = df_cn["Cumulative_cases"].values
realD = df_cn["Cumulative_deaths"].values
realK = realK / realK.max()
realD = realD / realD.max()

ax1.set_xlabel("Date")
ax1.set_ylabel("Cumulative_cases", color="b")
ax2.set_ylabel("Cumulative_deaths", color="r")


# pick the same number of data points
index = np.linspace(0, len(st) - 1, len(realK)).astype(int)

# resample K and D:
K_rescaled = st[index, 4]
D_rescaled = st[index, 5]
K_rescaled = K_rescaled / K_rescaled.max()
D_rescaled = D_rescaled / D_rescaled.max()

ax1.plot(K_rescaled, color="b", label="Simulated cases")
ax2.plot(D_rescaled, color="r", label="Simulated deaths")
ax1.plot(realK, color="b", linestyle="--", label="Real cases")
ax2.plot(realD, color="r", linestyle="--", label="Real deaths")

plt.title("Cumulative cases and deaths in China < 2020-04-10")
# plt.show()

# Save
plt.savefig(f"./output/SEIR_simulation_{alpha}_{mu}_{beta}_{gamma}_{sigma}_{S0}.png")
