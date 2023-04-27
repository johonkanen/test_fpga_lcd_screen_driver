import os
import sys
import time
import numpy as np
from matplotlib import pyplot

abs_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(abs_path + '/fpga_uart_pc_software/')
sys.path.append(abs_path + '/source/vhdl_lcd_screen_driver/python_files/')

from lcdprint import stream_lcd

from uart_communication_functions import *
uart = uart_link("COM15", 5e6)

uart.request_data_from_address(30000) 
print("read plot buffer : ", uart.request_data_from_address(20001)) 
print("read plot buffer : ", uart.request_data_from_address(20002)) 
uart.request_data_from_address(30001) 
print("read plot buffer : ", uart.request_data_from_address(20001)) 
print("read plot buffer : ", uart.request_data_from_address(20002)) 


