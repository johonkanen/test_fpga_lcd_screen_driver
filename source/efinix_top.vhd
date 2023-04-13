library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
------------------------------------------------------------------------
package ram_write_pkg is

    type ram_write_port_record is record
        write_enabled_with_1    : std_logic;
        write_buffer            : std_logic_vector(15 downto 0);
        write_address           : integer;
        write_is_ready_pipeline : std_logic_vector(1 downto 0);
    end record;

    constant init_ram_write_port : ram_write_port_record := ('0', (others => '0'), 0, (others => '0'));

------------------------------------------------------------------------
    procedure create_ram_write_port (
        signal self : inout ram_write_port_record);
------------------------------------------------------------------------

    procedure write_ram (
        signal self : inout ram_write_port_record;
        data_in     : in std_logic_vector(15 downto 0);
        address_in  : in integer);

------------------------------------------------------------------------
    procedure write_data_to_ram (
        data_in                     : in std_logic_vector(15 downto 0);
        address_in                  : in integer;
        signal write_enabled_with_1 : inout std_logic;
        signal write_buffer         : inout std_logic_vector(15 downto 0);
        signal write_address        : inout integer);

------------------------------------------------------------------------
    function ram_write_is_ready ( self : ram_write_port_record)
        return boolean;

end package ram_write_pkg;

package body ram_write_pkg is
------------------------------------------------------------------------
    procedure create_ram_write_port
    (
        signal self : inout ram_write_port_record
    ) is
    begin
        self.write_is_ready_pipeline <= self.write_is_ready_pipeline(0) & '0';
        self.write_enabled_with_1 <= '0';
    end create_ram_write_port;
------------------------------------------------------------------------
    procedure write_ram
    (
        signal self : inout ram_write_port_record;
        data_in     : in std_logic_vector(15 downto 0);
        address_in  : in integer
    ) is
    begin
        self.write_enabled_with_1       <= '1';
        self.write_buffer               <= data_in;
        self.write_address              <= address_in;
        self.write_is_ready_pipeline(0) <= '1';
    end write_ram;
------------------------------------------------------------------------
    function ram_write_is_ready
    (
        self : ram_write_port_record
    )
    return boolean
    is
    begin
        return self.write_is_ready_pipeline(self.write_is_ready_pipeline'left) = '1';
    end ram_write_is_ready;
------------------------------------------------------------------------
    procedure write_data_to_ram
    (
        data_in                     : in std_logic_vector(15 downto 0);
        address_in                  : in integer;
        signal write_enabled_with_1 : inout std_logic;
        signal write_buffer         : inout std_logic_vector(15 downto 0);
        signal write_address        : inout integer
    ) is
    begin
        write_enabled_with_1 <= '1';
        write_buffer         <= data_in;
        write_address        <= address_in;
    end write_data_to_ram;
------------------------------------------------------------------------
end package body ram_write_pkg;

------------------------------------------------------------------------
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.ram_configuration_pkg.all;
    use work.fpga_interconnect_pkg.all;
    use work.ram_read_port_pkg.all;
    use work.ram_write_pkg.all;

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

    signal ram_write_port : ram_write_port_record := init_ram_write_port;


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
    begin
        if rising_edge(clock_120Mhz) then

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
        ------------------------------------------------------------------------
            -- create_ram_write_port(ram_write_port);
            ram_write_port.write_is_ready_pipeline <= ram_write_port.write_is_ready_pipeline(0) & '0';
            ram_write_port.write_enabled_with_1    <= '0';
            if ram_write_port.write_enabled_with_1 = '1' then
                test_ram(write_address) <= write_buffer;
            end if;

            if write_from_bus_is_requested(bus_from_communications) then
                write_data_to_ram(
                    data_in              => std_logic_vector(to_unsigned(get_data(bus_from_communications),16)),
                    address_in           => write_address,
                    write_enabled_with_1 => ram_write_port.write_enabled_with_1,
                    write_buffer         => write_buffer,
                    write_address        => write_address);

                ram_write_port.write_is_ready_pipeline(0) <= '1';



            end if;

            if ram_write_is_ready(ram_write_port) then
                if write_address < 1023 then
                    write_address <= write_address + 1;
                else
                    write_address <= 0;
                end if;
            end if;
        ------------------------------------------------------------------------

        end if;
    end process;

    u_communications : entity work.fpga_communications
    port map(clock_120Mhz, uart_rx, uart_tx, bus_to_communications, bus_from_communications);

end rtl;
