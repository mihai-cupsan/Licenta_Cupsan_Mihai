library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cu_main_dec is
  Port (
  OPcode : in std_logic_vector(5 downto 0);
  MemtoReg: out std_logic;
  MemWrite: out std_logic;
  Branch: out std_logic;
  ALUsrc: out std_logic;
  RegDst: out std_logic;
  RegWrite: out std_logic;
  ALUOp: out std_logic_vector(1 downto 0);
  Jump: out std_logic
   );
end cu_main_dec;

architecture Behavioral of cu_main_dec is
begin
---incerc sa rezolv problema cu jump-ul
    process(OPcode)
    begin   
        case OPcode is
        when "000000" =>        --r type    
            RegWrite <= '1';
            RegDst <='1';
            AluSrc <= '0';
            Branch <= '0';
            MemWrite <= '0';
            MemtoReg <= '0';
            ALUOp <= "10";
             Jump<='0';
       when "100011" =>           --lw
            RegWrite <= '1';
            RegDst <='0';
            AluSrc <= '1';
            Branch <= '0';
            MemWrite <= '0';
            MemtoReg <= '1';
            ALUOp <= "00";
             Jump<='0';
       when "101011" =>         --sw
            RegWrite <= '0';
            RegDst <='0'; ---
            AluSrc <= '1';
            Branch <= '0';
            MemWrite <= '1';
            MemtoReg <= '0'; ---
            ALUOp <= "00";
             Jump<='0';
       when "000100" =>     --beq
            RegWrite <= '0';
            RegDst <='0'; ---
            AluSrc <= '0';
            Branch <= '1';
            MemWrite <= '0';
            MemtoReg <= '0'; ---
            ALUOp <= "01";
            Jump <='0';
      when "000101" =>  -- bne (Branch if Not Equal)
            RegWrite <= '0'; RegDst <= '0'; AluSrc <= '0'; Branch <= '1'; 
            MemWrite <= '0'; MemtoReg <= '0'; ALUOp <= "01";Jump<='0';
      when "001100" =>  -- andi (And Immediate)
            RegWrite <= '1'; RegDst <= '0'; AluSrc <= '1'; Branch <= '0'; 
            MemWrite <= '0'; MemtoReg <= '0'; ALUOp <= "11"; Jump<='0';
      when "001000" =>
            RegWrite <= '1';  --addi
            RegDst <='0';
            AluSrc <= '1';
            Branch <= '0';
            MemWrite <= '0';
            MemtoReg <= '0';
            ALUOp <= "00";
            Jump<='0';
      when "001101" =>  -- ori (Or Immediate)
            RegWrite <= '1'; RegDst <= '0'; AluSrc <= '1'; Branch <= '0'; 
            MemWrite <= '0'; MemtoReg <= '0'; ALUOp <= "11";  Jump<='0';
      when "001010" =>  -- slti (Set on Less Than Immediate)
            RegWrite <= '1'; RegDst <= '0'; AluSrc <= '1'; Branch <= '0'; 
            MemWrite <= '0'; MemtoReg <= '0'; ALUOp <= "11";   Jump<='0';
      when "000010" => -- j (Jump)
            RegWrite <= '0'; RegDst <= '0'; AluSrc <= '0'; Branch <= '0';
            MemWrite <= '0'; MemtoReg <= '0'; ALUOp <= "00"; Jump <= '1';
        when others =>
            RegWrite <= '0';
            RegDst  <= '0';
            AluSrc <= '0';
            Branch <= '0';
            MemWrite <= '0';
            MemtoReg <= '0';
            ALUOp <= "00";
            Jump<='0';
        end case;
    end process;
end Behavioral;
