import os
import sys
import time
import numpy as np
from matplotlib import pyplot

abs_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(abs_path + '/fpga_uart_pc_software/')

from uart_communication_functions import *
uart = uart_link("COM15", 5e6)

def read_spi_register(register):
    uart.request_data_from_address(int(register,16) + 30000) 
    print("read plot buffer : ", uart.request_data_from_address(20001)) 
    print("read plot buffer : ", uart.request_data_from_address(20002)) 

read_spi_register("39")
read_spi_register("4")
read_spi_register("9")
read_spi_register("0A")

