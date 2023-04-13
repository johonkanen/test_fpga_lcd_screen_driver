library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.ram_data_width_pkg.all;

package ram_read_port_pkg is

    type ram_read_port_record is record
        read_enabled_with_1 : std_logic;
        read_address        : integer;
        read_buffer         : std_logic_vector(15 downto 0);
        read_ready_pipeline : std_logic_vector(1 downto 0);
    end record;

    constant init_ram_read_port : ram_read_port_record := ('0', 0, (others => '0'), (others => '0'));

    procedure create_ram_read_port (
        signal self : inout ram_read_port_record);

    procedure request_data_from_ram (
        signal self : out ram_read_port_record;
        read_address : in integer);

    function ram_read_is_requested ( self : ram_read_port_record)
        return boolean;

    function ram_read_is_ready ( self : ram_read_port_record)
        return boolean;

    function get_ram_read_address ( self : ram_read_port_record)
        return integer;

    function get_ram_data ( self : ram_read_port_record)
        return std_logic_vector;

end package ram_read_port_pkg;

------------------------------------------------------------------------
package body ram_read_port_pkg is

    procedure create_ram_read_port
    (
        signal self : inout ram_read_port_record

    ) is
        constant left : integer := self.read_ready_pipeline'left;
    begin

        self.read_enabled_with_1 <= '0';
        self.read_ready_pipeline <= self.read_ready_pipeline(left-1 downto 0) & '0';
        
    end create_ram_read_port;

    procedure request_data_from_ram
    (
        signal self : out ram_read_port_record;
        read_address : in integer
    ) is
    begin
        self.read_enabled_with_1    <= '1';
        self.read_ready_pipeline(0) <= '1';
        self.read_address <= read_address;
    end request_data_from_ram;

    function ram_read_is_ready
    (
        self : ram_read_port_record
    )
    return boolean
    is
    begin
        return self.read_ready_pipeline(self.read_ready_pipeline'left) = '1';
    end ram_read_is_ready;

    function get_ram_read_address
    (
        self : ram_read_port_record
    )
    return integer
    is
    begin
        return self.read_address;
    end get_ram_read_address;

    function get_ram_data
    (
        self : ram_read_port_record
    )
    return std_logic_vector 
    is
    begin
        return self.read_buffer;
    end get_ram_data;

    function ram_read_is_requested
    (
        self : ram_read_port_record
    )
    return boolean
    is
    begin
        return self.read_enabled_with_1 = '1';
    end ram_read_is_requested;

end package body ram_read_port_pkg;
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.fpga_interconnect_pkg.all;
    use work.ram_write_port_pkg.all;
    use work.ram_read_port_pkg.all;

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

    type std_array is array (integer range <>) of ramtype;

    signal test_ram       : std_array(0 to 1023)  := (others => (15 downto 0 => x"cccc", others => '0'));
    signal ram_read_port  : ram_read_port_record  := init_ram_read_port;
    signal ram_write_port : ram_write_port_record := init_ram_write_port;

    signal read_address : integer range 0 to 1023 := 0;
    signal write_address : integer range 0 to 1023 := 0;

begin

    test_communications : process(clock_120Mhz)

    begin
        if rising_edge(clock_120Mhz) then

            init_bus(bus_to_communications);

            connect_read_only_data_to_address(bus_from_communications , bus_to_communications , 10    , 44252);
            connect_read_only_data_to_address(bus_from_communications , bus_to_communications , 100   , 44253);
            connect_read_only_data_to_address(bus_from_communications , bus_to_communications , 1001  , 44254);
            connect_read_only_data_to_address(bus_from_communications , bus_to_communications , 1002  , 44255);

            if ram_read_is_ready(ram_read_port) then
                write_data_to_address(bus_to_communications, 0, to_integer(unsigned(get_ram_data(ram_read_port))));
            end if;
            ------------------------------------------------------------------------
            create_ram_read_port(ram_read_port);
            if ram_read_is_requested(ram_read_port) then
                ram_read_port.read_buffer <= test_ram(get_ram_read_address(ram_read_port));
            end if;

            create_ram_write_port(ram_write_port);
            if write_to_ram_is_requested(ram_write_port) then
                test_ram(ram_write_port.write_address) <= ram_write_port.write_buffer;
            end if;
            ------------------------------------------------------------------------

            if data_is_requested_from_address(bus_from_communications, get_address(bus_from_communications)) then
                request_data_from_ram(ram_read_port, get_address(bus_from_communications));
            end if;
        ------------------------------------------------------------------------

            if write_from_bus_is_requested(bus_from_communications) then
                write_ram(ram_write_port,
                          get_data(bus_from_communications),
                          get_address(bus_from_communications));
            end if;
        ------------------------------------------------------------------------

        end if; --rising_edge
    end process test_communications;	

    u_communications : entity work.fpga_communications
    port map(clock_120Mhz, uart_rx, uart_tx, bus_to_communications, bus_from_communications);

end rtl;
