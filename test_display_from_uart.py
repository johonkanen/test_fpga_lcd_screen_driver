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

# print("test reading data from register 10")
print("this should be 44252 : ", uart.request_data_from_address(512)) 
print("this should be 44253 : ", uart.request_data_from_address(512)) 
print("this should be 44254 : ", uart.request_data_from_address(512)) 
print("this should be 44255 : ", uart.request_data_from_address(513)) 
print("this should be 44255 : ", uart.request_data_from_address(512)) 
# print("this should be increasing every time it is read : ")


uart.request_fpga_controlled_data_stream_from_address(10000, 320*480)
uart.send_data_request_to_address(10000)

xsize = 480
ysize = 320

d = np.zeros([ysize,xsize])
d = uart.get_streamed_data(320*480)

stream_lcd(d, xsize, ysize)

uart.request_data_stream_from_address(512, 100)
print("data that was streamed from uart :")
print(uart.get_streamed_data(100))
# data = np.zeros(512)
# for i in range(512):
#     uart.send_data_request_to_address(512)
#     data[i] = uart.get_data_from_uart()
#
# pyplot.plot(data)
# pyplot.show()

# for i in range(1024):
#     uart.write_data_to_address(i, 1023-i)
# for i in range(1024):
#     print(uart.request_data_from_address(i))
