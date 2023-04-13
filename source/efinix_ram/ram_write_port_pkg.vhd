library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.ram_data_width_pkg.ram_port_width;
------------------------------------------------------------------------
package ram_write_port_pkg is

    subtype ramtype is std_logic_vector(ram_port_width-1 downto 0);

    type ram_write_port_record is record
        write_enabled_with_1    : std_logic;
        write_buffer            : std_logic_vector(ram_port_width-1 downto 0);
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
        data_in     : in std_logic_vector;
        address_in  : in integer);

    procedure write_ram (
        signal self : inout ram_write_port_record;
        data_in     : in integer;
        address_in  : in integer);

------------------------------------------------------------------------
    function write_to_ram_is_requested ( self : ram_write_port_record)
        return boolean;

------------------------------------------------------------------------
    function ram_write_is_ready ( self : ram_write_port_record)
        return boolean;

end package ram_write_port_pkg;

package body ram_write_port_pkg is
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
        data_in     : in std_logic_vector;
        address_in  : in integer
    ) is
    begin
        self.write_enabled_with_1 <= '1';
        self.write_buffer         <= data_in;
        self.write_address        <= address_in;

        self.write_is_ready_pipeline(0) <= '1';
    end write_ram;
------------------------------------------------------------------------
    procedure write_ram
    (
        signal self : inout ram_write_port_record;
        data_in     : in integer;
        address_in  : in integer
    ) is
    begin
        write_ram(self, std_logic_vector(to_unsigned(data_in,ram_port_width)), address_in);
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
    function write_to_ram_is_requested
    (
        self : ram_write_port_record
    )
    return boolean
    is
    begin
        return self.write_enabled_with_1 = '1';
    end write_to_ram_is_requested;
------------------------------------------------------------------------
end package body ram_write_port_pkg;
