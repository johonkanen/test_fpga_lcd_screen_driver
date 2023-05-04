------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

    use work.fpga_interconnect_pkg.all;
    use work.ram_write_port_pkg.all;
    use work.ram_read_port_pkg.all;

    use work.image_configuration_pkg.all;
    use work.lcd_driver_pkg.all;
    use work.pixel_position_counter_pkg.all;
    use work.pixel_image_plotter_pkg.all;

    use work.spi_pkg.all;

entity efinix_top is
    port (
        clock_120Mhz : in std_logic;
        uart_rx      : in std_logic;
        uart_tx      : out std_logic;
    -- lcd control io
        lcd_spi_data_in            : in std_logic;
        data_when_1_command_when_0 : out std_logic;
        lcd_cs                     : out std_logic;
        lcd_reset_when_0           : out std_logic; -- reset during power on
        lcd_spi_clock              : out std_logic;
        lcd_spi_data_out           : out std_logic;
        lcd_led                    : out std_logic
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

------------------------------------------------------------------------
    type std_array is array (integer range <>) of ramtype;

    ------------
    function init_ram_with_measurement_values return std_array 
    is
        variable returned_value : std_array(0 to 511) := (others => (others => '0'));
        variable int_sine_pixel_position : integer;
        constant x_max : integer := 479;
        constant y_max : integer := 319;
        constant frequency : real := 3.5;
    begin

        for counter in 0 to 479 loop
            int_sine_pixel_position := y_max - (integer(round(160.0 + 150.0*sin(real(counter)/real(x_max)*2.0*frequency*math_pi)))); 
            returned_value(counter) := std_logic_vector(to_unsigned(int_sine_pixel_position, ramtype'length));
        end loop;

        return returned_value;
        
    end init_ram_with_measurement_values;
------------------------------------------------------------------------
    signal test_ram       : std_array(0 to 511)  := init_ram_with_measurement_values;

    signal uart_requested : boolean := false;
    signal read_address : integer range 0 to 511 := 0;

    signal lcd_spi_driver : spi_record := init_spi;
    signal lcd_cs_state : std_logic := '1';

begin

    lcd_reset_when_0 <= '1';

------------------------------------------------------------------------
    test_communications : process(clock_120Mhz)

        alias ram_read_port is pixel_image_plotter.read_port;
        alias ram_write_port is pixel_image_plotter.ram_write_port;

    begin
        if rising_edge(clock_120Mhz) then

            init_bus(bus_from_top);
            connect_data_to_address(bus_from_communications, bus_from_top, 513, read_address);
            connect_read_only_data_to_address(bus_from_communications, bus_from_top, 20e3+1, get_read_data(lcd_spi_driver)(31 downto 16));
            connect_read_only_data_to_address(bus_from_communications, bus_from_top, 20e3+2, get_read_data(lcd_spi_driver)(15 downto 0));
            create_pixel_image_plotter(pixel_image_plotter, lcd_driver_in, lcd_driver_out);
        ------------------------------------------------------------------------
            if ram_read_is_requested(ram_read_port) then
                ram_read_port.read_buffer <= test_ram(get_ram_read_address(ram_read_port));
            end if;

            if write_to_ram_is_requested(ram_write_port) then
                test_ram(ram_write_port.write_address) <= ram_write_port.write_buffer;
            end if;

        ------------------------------------------------------------------------
            if data_is_requested_from_address(bus_from_communications, 512) then
                request_data_from_ram(ram_read_port, read_address);
                read_address <= read_address + 1;
                uart_requested <= true;
            end if;

            if uart_requested then
                if ram_read_is_ready(ram_read_port) then
                    write_data_to_address(bus_from_top, 0, get_ram_data(ram_read_port));
                    uart_requested <= false;
                end if;
            end if;

            if data_is_requested_from_address(bus_from_communications, 10e3) then
                request_image(pixel_image_plotter);
            end if;
        ------------------------------------------------------------------------
            create_spi(lcd_spi_driver, lcd_spi_clock, lcd_cs, lcd_spi_data_out, lcd_spi_data_in);
            if data_is_requested_from_address_range(bus_from_communications, 30e3, 31e3) then
                read_32_bit_data(lcd_spi_driver, std_logic_vector(to_unsigned(get_address(bus_from_communications)- 30e3, 8)));
                lcd_cs_state <= not lcd_cs_state;
            end if;

        end if; --rising_edge
    end process test_communications;	
    lcd_led <= lcd_cs_state;
    data_when_1_command_when_0 <= '0';

------------------------------------------------------------------------
    combine_buses : process(clock_120Mhz)
    begin
        if rising_edge(clock_120Mhz) then
            bus_to_communications <= bus_from_top and bus_from_lcd_driver;
        end if; --rising_edge
    end process combine_buses;	

------------------------------------------------------------------------
    u_communications : entity work.fpga_communications
    port map(clock_120Mhz, uart_rx, uart_tx, bus_to_communications, bus_from_communications);

------------------------------------------------------------------------
    u_lcd_driver : entity work.lcd_driver_w_bus
    generic map(1199)
    port map(clock_120Mhz, lcd_driver_in, lcd_driver_out, bus_from_communications, bus_from_lcd_driver);
------------------------------------------------------------------------
end rtl;
