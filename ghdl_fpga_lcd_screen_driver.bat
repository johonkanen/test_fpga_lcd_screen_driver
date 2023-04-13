echo off

echo %project_root%
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse --show-toplevel`) DO (
SET project_root=%%F
)
SET source=%project_root%/source

ghdl -a --ieee=synopsys --std=08 %source%/fpga_communication/hVHDL_fpga_interconnect/interconnect_configuration/data_15_address_15_bit_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %source%/fpga_communication/hVHDL_fpga_interconnect/fpga_interconnect_pkg.vhd

ghdl -a --ieee=synopsys --std=08 %source%/vhdl_lcd_screen_driver/hVHDL_memory_library/fpga_ram/ram_configuration/ram_configuration_16x1024_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %source%/vhdl_lcd_screen_driver/hVHDL_memory_library/fpga_ram/ram_read_port_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %source%/vhdl_lcd_screen_driver/hVHDL_memory_library/fpga_ram/ram_write_port_pkg.vhd


ghdl -a --ieee=synopsys --std=08 %source%/fpga_communication/hVHDL_uart/uart_transreceiver/uart_rx/uart_rx_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %source%/fpga_communication/hVHDL_uart/uart_transreceiver/uart_tx/uart_tx_pkg.vhd
ghdl -a --ieee=synopsys --std=08 %source%/fpga_communication/hVHDL_uart/uart_protocol/uart_protocol_pkg.vhd

ghdl -a --ieee=synopsys --std=08 %source%/fpga_communication/communications.vhd
