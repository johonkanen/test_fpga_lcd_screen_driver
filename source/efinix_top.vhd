library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.fpga_interconnect_pkg.all;

entity efinix_top is
    port (
        clock   : std_logic;
        uart_rx : in std_logic;
        uart_tx : out std_logic

        -- tft_spi_simo  : in std_logic
        -- tft_spi_mosi  : out std_logic
        -- tft_spi_cs    : out std_logic
        -- tft_spi_clock : out std_logic
        -- tft_reset     : out std_logic
        -- tft_1_when_register_and_0_when_command : out std_logic
    );
end entity efinix_top;


architecture rtl of efinix_top is

    signal bus_to_communications   : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_communications : fpga_interconnect_record := init_fpga_interconnect;

begin

    test_communications : process(clock)
        
    begin
        if rising_edge(clock) then
            init_bus(bus_to_communications);
            connect_read_only_data_to_address(bus_to_communications, bus_from_communications, 10, 44252);
            
        end if; --rising_edge
    end process test_communications;	

    u_communications : entity work.fpga_communications
    port map(clock, uart_rx, uart_tx, bus_to_communications, bus_from_communications);

end rtl;
