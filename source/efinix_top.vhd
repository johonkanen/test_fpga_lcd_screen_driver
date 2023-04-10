library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

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


begin


end rtl;
