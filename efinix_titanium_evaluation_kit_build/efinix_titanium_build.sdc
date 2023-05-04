
# Efinity Interface Designer SDC
# Version: 2022.2.322.3.16
# Date: 2023-04-10 14:55

# Copyright (C) 2017 - 2022 Efinix Inc. All rights reserved.

# Device: Ti60F225
# Project: efinix_titanium_build
# Timing Model: C4 (final)

# PLL Constraints
#################
create_clock -period 10.0000 clock_100Mhz
create_clock -period 8.3333 clock_120Mhz

# GPIO Constraints
####################
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {uart_rx}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {uart_rx}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {uart_tx}]
# set_output_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {uart_tx}]

# HSIO GPIO Constraints
#########################
