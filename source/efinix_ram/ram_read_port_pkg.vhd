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
