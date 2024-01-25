#!/bin/bash
# Author: Martín Gil Blanco

num_decimal=16
num_binario=10000
num_hexadecimal=10

echo "---------------------------------------------------"
echo "Operaciones de conversión para el número decimal $num_decimal"
echo "---------------------------------------------------"

# Convertir decimal a binario con bc
num_binario_dec=$(echo "obase=2; ibase=10; $num_decimal" | bc)
echo "Decimal a binario: $num_decimal a binario es $num_binario_dec"

# Convertir binario a decimal con bc
num_decimal_bin=$(echo "obase=10; ibase=2; $num_binario" | bc)
echo "Binario a decimal: $num_binario a decimal es $num_decimal_bin"

# Convertir decimal a hexadecimal con bc
num_hexadecimal_dec=$(echo "obase=16; ibase=10; $num_decimal" | bc)
echo "Decimal a hexadecimal: $num_decimal a hexadecimal es $num_hexadecimal_dec"

# Puedes convertir binario a hexadecimal indirectamente
# Primero, convierte binario a decimal y luego decimal a hexadecimal
num_decimal_bin_hex=$(echo "obase=16; ibase=2; $num_binario" | bc)
echo "Binario a hexadecimal: $num_binario a hexadecimal es $num_decimal_bin_hex"
