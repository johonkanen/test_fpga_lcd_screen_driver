import os
import sys
import time
import numpy as np
from matplotlib import pyplot

abs_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(abs_path + '/fpga_uart_pc_software/')

from uart_communication_functions import *
uart = uart_link("COM9", 5e6)

print("test reading data from register 10")
print("this should be 44252 : ", uart.request_data_from_address(10)) 
print("this should be 44253 : ", uart.request_data_from_address(100)) 
print("this should be 44254 : ", uart.request_data_from_address(1001)) 
print("this should be 44255 : ", uart.request_data_from_address(1002)) 
print("this should be 44255 : ", uart.request_data_from_address(1002)) 
print("this should be increasing every time it is read : ")
# for i in range(1024):
#     uart.write_data_to_address(i, 1023-i)
for i in range(1024):
    print(uart.request_data_from_address(i))
