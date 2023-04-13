------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.fpga_interconnect_pkg.all;
    use work.ram_write_port_pkg.all;
    use work.ram_read_port_pkg.all;

    use work.image_configuration_pkg.all;
    use work.lcd_driver_pkg.all;
    use work.lcd_pixel_driver_pkg.all;
    use work.pixel_image_plotter_pkg.all;

entity efinix_top is
    port (
        clock_120Mhz   : in std_logic;
        uart_rx : in std_logic;
        uart_tx : out std_logic
    );
end entity efinix_top;


architecture rtl of efinix_top is

    signal bus_to_communications   : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_communications : fpga_interconnect_record := init_fpga_interconnect;

    signal bus_from_lcd_driver : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_top : fpga_interconnect_record := init_fpga_interconnect;

    signal ram_read_port  : ram_read_port_record  := init_ram_read_port;
    signal ram_write_port : ram_write_port_record := init_ram_write_port;

    signal lcd_driver_in          : lcd_driver_input_record       := init_lcd_driver;
    signal lcd_driver_out         : lcd_driver_output_record      := init_lcd_driver_out;

    signal pixel_image_plotter : pixel_image_plotter_record := init_pixel_image_plotter;
    type std_array is array (integer range <>) of ramtype;
    signal test_ram       : std_array(0 to 1023)  := (others => (15 downto 0 => x"cccc", others => '0'));

begin

    test_communications : process(clock_120Mhz)

        alias ram_read_port is pixel_image_plotter.read_port;
        alias ram_write_port is pixel_image_plotter.ram_write_port;

    begin
        if rising_edge(clock_120Mhz) then

            init_bus(bus_from_top);
            create_pixel_image_plotter(pixel_image_plotter, lcd_driver_in, lcd_driver_out);
            ------------------------------------------------------------------------
            if ram_read_is_requested(ram_read_port) then
                ram_read_port.read_buffer <= test_ram(get_ram_read_address(ram_read_port));
            end if;

            if write_to_ram_is_requested(ram_write_port) then
                test_ram(ram_write_port.write_address) <= ram_write_port.write_buffer;
            end if;
            ------------------------------------------------------------------------

            if ram_read_is_ready(ram_read_port) then
                write_data_to_address(bus_from_top, 0, get_ram_data(ram_read_port));
            end if;

            if data_is_requested_from_address(bus_from_communications, get_address(bus_from_communications)) then
                request_data_from_ram(ram_read_port, get_address(bus_from_communications));
            end if;
        ------------------------------------------------------------------------

            if write_from_bus_is_requested(bus_from_communications) then
                write_ram(ram_write_port,
                          get_data(bus_from_communications),
                          get_address(bus_from_communications));
            end if;

            if data_is_requested_from_address(bus_from_communications, 10e3) then
                request_image(pixel_image_plotter);
            end if;
        ------------------------------------------------------------------------

        end if; --rising_edge
    end process test_communications;	

    combine_buses : process(clock_120Mhz)
        
    begin
        if rising_edge(clock_120Mhz) then
            bus_to_communications <= bus_from_top and bus_from_lcd_driver;
        end if; --rising_edge
    end process combine_buses;	

    u_communications : entity work.fpga_communications
    port map(clock_120Mhz, uart_rx, uart_tx, bus_to_communications, bus_from_communications);

------------------------------------------------------------------------
    u_lcd_driver : entity work.lcd_driver_w_bus
    port map(clock_120Mhz, lcd_driver_in, lcd_driver_out, bus_from_communications, bus_from_lcd_driver);
------------------------------------------------------------------------

end rtl;
