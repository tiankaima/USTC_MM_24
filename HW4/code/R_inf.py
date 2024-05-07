# implict solve 1- R_inf - e^(- R_0 R_inf) = 0
# given R_0, solve R_inf
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import fsolve

R_0 = np.linspace(0.1, 10, 100)

# solve R_inf
R_inf = np.zeros(R_0.shape)
for i in range(len(R_0)):
    R_inf[i] = fsolve(lambda x: np.exp(-R_0[i] * x) - 1 + x, 0.5)

# plot
plt.plot(R_0, R_inf)
plt.xlabel('R_0')
plt.ylabel('R_inf')

plt.savefig('./output/R_inf.png')
# plt.show()