echo off

echo %project_root%
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)
SET source=%project_root%/source

ghdl -a --ieee=synopsys --std=08 %source%/fpga_communication/hVHDL_fpga_interconnect/interconnect_configuration/data_15_address_15_bit_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %source%/fpga_communication/hVHDL_fpga_interconnect/fpga_interconnect_pkg.vhd

rem ghdl -a --ieee=synopsys --std=08 %source%/vhdl_lcd_screen_driver/hVHDL_memory_library/fpga_ram/ram_configuration/ram_configuration_16x1024_pkg.vhd
rem ghdl -a --ieee=synopsys --std=08 %source%/vhdl_lcd_screen_driver/hVHDL_memory_library/fpga_ram/ram_read_port_pkg.vhd
rem ghdl -a --ieee=synopsys --std=08 %source%/vhdl_lcd_screen_driver/hVHDL_memory_library/fpga_ram/ram_write_port_pkg.vhd


ghdl -a --ieee=synopsys --std=08 %source%/vhdl_lcd_screen_driver/lcd_spi_driver/lcd_spi_driver_pkg.vhd

ghdl -a --ieee=synopsys --std=08 %source%/vhdl_lcd_screen_driver/ram/ram_configuration/data_width_16bit_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %source%/vhdl_lcd_screen_driver/ram/ram_write_port_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %source%/vhdl_lcd_screen_driver/ram/ram_read_port_pkg.vhd

SET project_root=%project_root%/source/vhdl_lcd_screen_driver
ghdl -a --ieee=synopsys --std=08 %project_root%\image_configuration\image_configuration_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %project_root%\pixel_position_counter\pixel_position_counter_pkg.vhd

ghdl -a --ieee=synopsys --std=08 %project_root%\lcd_driver\lcd_driver_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %project_root%\lcd_driver\lcd_driver.vhd
ghdl -a --ieee=synopsys --std=08 %project_root%\lcd_driver\lcd_driver_w_bus.vhd
ghdl -a --ieee=synopsys --std=08 %project_root%\pixel_image_plotter\pixel_image_plotter_pkg.vhd


ghdl -a --ieee=synopsys --std=08 %source%/fpga_communication/hVHDL_uart/uart_transreceiver/uart_rx/uart_rx_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %source%/fpga_communication/hVHDL_uart/uart_transreceiver/uart_tx/uart_tx_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %source%/fpga_communication/hVHDL_uart/uart_protocol/uart_protocol_pkg.vhd

ghdl -a --ieee=synopsys --std=08 %source%/fpga_communication/communications.vhd
