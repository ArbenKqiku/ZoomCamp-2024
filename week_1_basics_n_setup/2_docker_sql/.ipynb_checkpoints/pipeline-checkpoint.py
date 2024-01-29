import pandas as pd

import sys

# this will print the system arguments, similar to environment variables in R
print(sys.argv)

# Number 0 is the filename, number 1 is whatever we pass
day = sys.argv[1]

print(f"job finished successfully for day = {day}")