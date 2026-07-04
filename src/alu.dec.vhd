library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_dec is
port(
opcode   : in  std_logic_vector(5 downto 0);
alu_op : in std_logic_vector(1 downto 0);
funct : in std_logic_vector(5 downto 0);
alu_ctrl : out std_logic_vector (2 downto 0)
);
end alu_dec;

architecture Behavioral of alu_dec is
begin

    process (alu_op,funct)
    begin
        case alu_op is
        
        when "00" => 
        alu_ctrl <= "010";
        
        when "01" => 
        alu_ctrl <= "110";
        
        when "10" =>
            case funct is
            when "100000" => alu_ctrl <= "010";
            when "100010" => alu_ctrl <= "110"; 
            when "100100" => alu_ctrl <= "000"; 
            when "100101" => alu_ctrl <= "001";
            when "101010" => alu_ctrl <= "111";
            when others =>
            alu_ctrl<="000"; 
            end case;
        
        when "11" => -- Immediate Logic Operations (I-Type)
             case opcode is
             when "001100" => alu_ctrl <= "000"; -- andi uses AND
             when "001101" => alu_ctrl <= "001"; -- ori uses OR
             when "001010" => alu_ctrl <= "111"; -- slti uses SLT
             when others   => alu_ctrl <= "000";
                            end case;
        
        when others =>
        alu_ctrl<="000";

        end case;
    end process;
end Behavioral;