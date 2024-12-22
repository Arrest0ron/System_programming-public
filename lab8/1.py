import random as rd

# Variant = 3

for Variant in range(23):
    rd.seed(Variant+643)
    print(Variant, [rd.randint(1, 3), rd.randint(1, 10)])