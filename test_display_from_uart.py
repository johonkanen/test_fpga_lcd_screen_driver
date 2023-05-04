import os
import sys
import time
import numpy as np
from matplotlib import pyplot


abs_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(abs_path + '/fpga_uart_pc_software/')
sys.path.append(abs_path + '/source/vhdl_lcd_screen_driver/python_lcd_tests/')

from lcd_plotter import lcd

xsize = 480
ysize = 320

lcd_plotter = lcd(xsize,ysize)

from uart_communication_functions import *
uart = uart_link("COM15", 5e6)

print("read plot buffer : ", uart.request_data_from_address(512)) 
print("read plot buffer : ", uart.request_data_from_address(512)) 
print("read plot buffer : ", uart.request_data_from_address(512)) 

print("read plot buffer pointer : ", uart.request_data_from_address(513)) 

print("read plot buffer : ", uart.request_data_from_address(512)) 

uart.write_data_to_address(513,0)
uart.request_data_stream_from_address(512, 512)
print("data from plot memory :")
print(uart.get_streamed_data(512))
uart.write_data_to_address(513,357)
print("read current plot buffer pointer : ",uart.request_data_from_address(513))
print("read plot buffer : ", uart.request_data_from_address(512)) 
print("read current plot buffer pointer should have increased by one : ",uart.request_data_from_address(513))

uart.request_fpga_controlled_data_stream_from_address(10000, 320*480)

xsize = 480
ysize = 320

d = np.zeros([ysize,xsize])
d = uart.get_streamed_data(320*480)

lcd_plotter.stream_lcd(d);
