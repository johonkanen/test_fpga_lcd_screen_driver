library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.ram_configuration_pkg.all;
    use work.fpga_interconnect_pkg.all;
    use work.ram_read_port_pkg.all;
    use work.ram_write_port_pkg.all;

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

    signal ram               : integer_array(0 to lookup_table_size - 1);
    signal ram_read_port     : ram_read_port_record;
    signal ram_write_port    : ram_write_port_record;
    signal read_counter : natural range 0 to lookup_table_size - 1 := 0;

    signal test_ram_write_counter : natural range 0 to 250 := 0;

    signal read_enabled_with_1 : std_logic := '0';
    type std_array is array (integer range <>) of std_logic_vector(15 downto 0);
    signal read_address : integer range 0 to 1023;
    signal read_buffer : std_logic_vector(15 downto 0);
    signal out_buffer  : std_logic_vector(15 downto 0);
    signal ram_read_is_ready : boolean := false;

    signal test_ram : std_array(0 to 1023) := (others => x"cccc");

    signal write_enabled_with_1 : std_logic := '0';
    signal write_address : integer range 0 to 1023;
    signal write_buffer : std_logic_vector(15 downto 0);


begin

    test_communications : process(clock_120Mhz)

    begin
        if rising_edge(clock_120Mhz) then

            init_bus(bus_to_communications);

            connect_read_only_data_to_address(bus_from_communications , bus_to_communications , 10    , 44252);
            connect_read_only_data_to_address(bus_from_communications , bus_to_communications , 100   , 44253);
            connect_read_only_data_to_address(bus_from_communications , bus_to_communications , 1001  , 44254);
            connect_read_only_data_to_address(bus_from_communications , bus_to_communications , 1002  , 44255);
            connect_read_only_data_to_address(bus_from_communications , bus_to_communications , 10001 , get_read_pointer(ram_read_port));

            if ram_read_is_ready then
                write_data_to_address(bus_to_communications, 0, to_integer(unsigned(read_buffer)));
            end if;


        end if; --rising_edge
    end process test_communications;	

    process(clock_120Mhz)
    ------------------------------------------------------------------------
        procedure write_data_to_ram
        (
            do_it : boolean
        ) is
        begin
            write_enabled_with_1 <= '1';
            write_buffer <= std_logic_vector(to_unsigned(get_data(bus_from_communications),16));
            if write_address < 1023 then
                write_address <= write_address + 1;
            else
                write_address <= 0;
            end if;
            
        end write_data_to_ram;
    ------------------------------------------------------------------------
        procedure make_ram_write
        (
            do_it : boolean
        ) is
        begin
            write_enabled_with_1 <= '0';
        end make_ram_write;
    ------------------------------------------------------------------------
    begin
        if rising_edge(clock_120Mhz) then

            make_ram_write(true);
            if write_enabled_with_1 = '1' then
                test_ram(write_address) <= write_buffer;
            end if;

            read_enabled_with_1 <= '0';
            if data_is_requested_from_address(bus_from_communications, 10000) then
                read_enabled_with_1 <= '1';
                if read_address < 1023 then
                    read_address <= read_address + 1;
                else
                    read_address <= 0;
                end if;
            end if;

            if read_enabled_with_1 = '1' then
                read_buffer <= test_ram(read_address);
                ram_read_is_ready <= true;
            else
                ram_read_is_ready <= false;
            end if;

            if write_from_bus_is_requested(bus_from_communications) then
                write_data_to_ram(true);
            end if;


        end if;
    end process;

    u_communications : entity work.fpga_communications
    port map(clock_120Mhz, uart_rx, uart_tx, bus_to_communications, bus_from_communications);

end rtl;
