library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity instruction_memory is
  Port (
        clock : in std_logic;
        address : in std_logic_vector(6 downto 0);
        data_out : out std_logic_vector(31 downto 0)); 
end instruction_memory;
 
architecture Behavioral of instruction_memory is
    type ROM_type is array (127 downto 0) of std_logic_vector (31 downto 0);

constant ROM : ROM_type := (
    0      => x"2001000A", -- addi $1, $0, 10
    1      => x"20020005", -- addi $2, $0, 5
    2      => x"00221820", -- add  $3, $1, $2
    3      => x"00222022", -- sub  $4, $1, $2
    others => x"00000000"
);

begin
    
    data_out <= ROM(to_integer(unsigned(address)));
end Behavioral;