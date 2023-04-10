library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.fpga_interconnect_pkg.all;

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

begin

    test_communications : process(clock_120Mhz)
    begin
        if rising_edge(clock_120Mhz) then
            init_bus(bus_to_communications);
            connect_read_only_data_to_address(bus_from_communications, bus_to_communications, 10, 44252);
            connect_read_only_data_to_address(bus_from_communications, bus_to_communications, 100, 44253);
            connect_read_only_data_to_address(bus_from_communications, bus_to_communications, 1001, 44254);
            connect_read_only_data_to_address(bus_from_communications, bus_to_communications, 1002, 44255);
            
        end if; --rising_edge
    end process test_communications;	

    u_communications : entity work.fpga_communications
    port map(clock_120Mhz, uart_rx, uart_tx, bus_to_communications, bus_from_communications);

end rtl;
