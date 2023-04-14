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
uart = uart_link("COM9", 5e6)

print("this should be 44252 : ", uart.request_data_from_address(512)) 
print("this should be 44253 : ", uart.request_data_from_address(512)) 
print("this should be 44254 : ", uart.request_data_from_address(512)) 
print("this should be 44255 : ", uart.request_data_from_address(513)) 
print("this should be 44255 : ", uart.request_data_from_address(512)) 

uart.write_data_to_address(513,0)
uart.request_data_stream_from_address(512, 512)
print(" :")
print(uart.get_streamed_data(512))
uart.write_data_to_address(513,0)
print(uart.request_data_from_address(513))

uart.request_fpga_controlled_data_stream_from_address(10000, 320*480)

xsize = 480
ysize = 320

d = np.zeros([ysize,xsize])
d = uart.get_streamed_data(320*480)

stream_lcd(d, xsize, ysize)
