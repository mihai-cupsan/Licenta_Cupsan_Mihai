library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg_file is
Port(
    clk : in  std_logic;
    rw  : in  std_logic;
    ra1 : in  std_logic_vector(4 downto 0);
    ra2 : in  std_logic_vector(4 downto 0);
    wa  : in  std_logic_vector(4 downto 0);
    wd  : in  std_logic_vector(31 downto 0);
    rd1 : out std_logic_vector(31 downto 0);
    reg6_out : out std_logic_vector(31 downto 0);
    rd2 : out std_logic_vector(31 downto 0)
);
end reg_file;

architecture Behavioral of reg_file is
    type reg_type is array (31 downto 0) of std_logic_vector(31 downto 0);
    signal reg : reg_type := (others => (others => '0'));

begin


    rd1 <= x"00000000" when ra1 = "00000" else reg(to_integer(unsigned(ra1)));
    rd2 <= x"00000000" when ra2 = "00000" else reg(to_integer(unsigned(ra2)));

    REGISTER_WRITE: process(clk)
    begin
        if falling_edge(clk) then
            if rw = '1' then
                if wa /= "00000" then -- Never overwrite register $0
                    reg(to_integer(unsigned(wa))) <= wd;
                end if;
            end if;
        end if;
    end process;
reg6_out <= reg(6);
end Behavioral;