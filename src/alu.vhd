library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port (
        A      : in  std_logic_vector(31 downto 0);
        B      : in  std_logic_vector(31 downto 0);
        ALUOp  : in  std_logic_vector(2 downto 0); 
        Result : out std_logic_vector(31 downto 0); 
        Zero   : out std_logic                      
    );
end ALU;

architecture Behavioral of ALU is
    signal result_temp : std_logic_vector(31 downto 0); 
begin

    process(A, B, ALUOp)
    begin
        result_temp <= (others => '0');

        case ALUOp is
            when "000" =>
                result_temp <= std_logic_vector(signed(A) and signed(B));
            when "001" =>
                result_temp <= std_logic_vector(signed(A) or signed(B));
            when "010" =>
                result_temp <= std_logic_vector(signed(A) + signed(B));
            when "110" =>
                result_temp <= std_logic_vector(signed(A) - signed(B));
            when "111" =>
            if signed(A) < signed(B) then
                                result_temp <= x"00000001";
                            else
                                result_temp <= x"00000000";
                            end if;
            when others => 
                result_temp <= (others => '0');
                
        end case;
    end process;

    Result <= result_temp;
    Zero <= '1' when A = B else '0';

end Behavioral;