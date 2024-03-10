#!/bin/bash
# Author: Martín Gil Blanco

# Lanzamiento de dado y moneda

dado=$(shuf -i 1-6 -n1)
moneda=$(shuf -e cara cruz -n1)
echo Al lanzar el dado ha salido $dado
echo Al lanzar la moneda ha salido $moneda
