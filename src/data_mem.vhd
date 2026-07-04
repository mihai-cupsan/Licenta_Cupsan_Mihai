library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity data_memory is
  Port (
        clock : in std_logic;
        WE: in std_logic;
        WD : in std_logic_vector(31 downto 0);
        A : in std_logic_vector(31 downto 0);
        RD : out std_logic_vector(31 downto 0)); 
end data_memory;

architecture Behavioral of data_memory is
type RW_type is array (0 to 63) of std_logic_vector (31 downto 0);
signal RW : RW_type;
signal addr_int : integer;
begin
    addr_int <= to_integer(signed(A));

    RD <= RW(addr_int) when (addr_int >= 0 and addr_int < 64) else (others => '0');

    MEMORY : process (clock)
    begin
        if rising_edge(clock) then
            if (addr_int >= 0) and (addr_int < 64) then
                if WE = '1' then
                    RW(addr_int) <= WD;
                end if;
            end if;
        end if;
    end process;

end Behavioral;