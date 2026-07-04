library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPS is
 Port ( 
    clk   : in std_logic;
    reset : in std_logic;
    led : out std_logic_vector(15 downto 0)
 );
end MIPS;

architecture Structural of MIPS is

    component reg_Pc is
        Port ( clk : in std_logic; reset : in std_logic; PC_In : in std_logic_vector(31 downto 0); PC_Out : out std_logic_vector(31 downto 0) );
    end component;

    component instruction_memory is
         Port (
           clock : in std_logic;
           address : in std_logic_vector(6 downto 0);
           data_out : out std_logic_vector(31 downto 0)); 
    end component;

    component control_unit is
        Port (
            clock : in std_Logic; OP : in std_logic_vector(5 downto 0); Funct : in std_logic_vector(5 downto 0);
            MemtoReg : out std_logic; MemWrite : out std_logic; Branch : out std_logic;
            ALUControl : out std_logic_vector(2 downto 0); ALUSrc : out std_logic;
            RegDst : out std_logic; RegWrite : out std_logic; Jump : out std_logic
        );
    end component;

    component reg_file is
        Port (
            clk : in std_logic; rw : in std_logic;
            ra1 : in std_logic_vector(4 downto 0); ra2 : in std_logic_vector(4 downto 0); wa : in std_logic_vector(4 downto 0);
            wd : in std_logic_vector(31 downto 0); rd1 : out std_logic_vector(31 downto 0); rd2 : out std_logic_vector(31 downto 0)
        );
    end component;

    component ALU is
        Port (
            A : in std_logic_vector(31 downto 0); B : in std_logic_vector(31 downto 0);
            ALUOp : in std_logic_vector(2 downto 0); Result : out std_logic_vector(31 downto 0); Zero : out std_logic
        );
    end component;

    component data_memory is
        Port ( clock : in std_logic; WE : in std_logic; WD : in std_logic_vector(31 downto 0); A : in std_logic_vector(31 downto 0); RD : out std_logic_vector(31 downto 0) );
    end component;
   --HAZARD
    signal PC_stall, IF_ID_stall, ID_EX_flush : std_logic;
    signal ForwardA, ForwardB : std_logic_vector(1 downto 0);

    --IF
    signal IF_PC, IF_PC_Plus4, IF_Instr, IF_PC_Next, PC_Next_Final : std_logic_vector(31 downto 0);
    
    --ID
    signal ID_PC_Plus4, ID_Instr, ID_rd1, ID_rd2, ID_SignImm : std_logic_vector(31 downto 0);
    signal ID_rs, ID_rt, ID_rd : std_logic_vector(4 downto 0);
    signal ID_RegWrite, ID_MemtoReg, ID_MemWrite, ID_ALUSrc, ID_RegDst, ID_Branch, ID_Jump : std_logic;
    signal ID_ALUControl : std_logic_vector(2 downto 0);

    -- EX 
    signal EX_PC_Plus4, EX_rd1, EX_rd2, EX_SignImm : std_logic_vector(31 downto 0);
    signal EX_rs, EX_rt, EX_rd, EX_WriteReg : std_logic_vector(4 downto 0);
    signal EX_RegWrite, EX_MemtoReg, EX_MemWrite, EX_ALUSrc, EX_RegDst, EX_Branch : std_logic;
    signal EX_ALUControl : std_logic_vector(2 downto 0);
    signal EX_ALUSrcA_Mux, EX_ALUSrcB_Mux, EX_ALU_Final_B, EX_ALUResult, EX_PC_Branch : std_logic_vector(31 downto 0);
    signal EX_Zero, EX_PCSrc : std_logic;

    -- MEM 
    signal MEM_ALUResult, MEM_WriteData, MEM_ReadData : std_logic_vector(31 downto 0);
    signal MEM_WriteReg : std_logic_vector(4 downto 0);
    signal MEM_RegWrite, MEM_MemtoReg, MEM_MemWrite : std_logic;

    -- WB 
    signal WB_ReadData, WB_ALUResult, WB_Result : std_logic_vector(31 downto 0);
    signal WB_WriteReg : std_logic_vector(4 downto 0);
    signal WB_RegWrite, WB_MemtoReg : std_logic;

begin
--HAZARD fowarding
    process(EX_rs, EX_rt, MEM_WriteReg, WB_WriteReg, MEM_RegWrite, WB_RegWrite)
    begin
        ForwardA <= "00"; ForwardB <= "00";
        if (MEM_RegWrite = '1' and MEM_WriteReg /= "00000" and MEM_WriteReg = EX_rs) then
            ForwardA <= "10";
        elsif (WB_RegWrite = '1' and WB_WriteReg /= "00000" and WB_WriteReg = EX_rs) then
            ForwardA <= "01";
        end if;
        -- Forwarding pentru operandul B
        if (MEM_RegWrite = '1' and MEM_WriteReg /= "00000" and MEM_WriteReg = EX_rt) then
            ForwardB <= "10";
        elsif (WB_RegWrite = '1' and WB_WriteReg /= "00000" and WB_WriteReg = EX_rt) then
            ForwardB <= "01";
        end if;
    end process;

    -- STALL
    process(ID_rs, ID_rt, EX_rt, EX_MemtoReg)
    begin
        if (EX_MemtoReg = '1' and (EX_rt = ID_rs or EX_rt = ID_rt)) then
            PC_stall <= '1'; IF_ID_stall <= '1'; ID_EX_flush <= '1';
        else
            PC_stall <= '0'; IF_ID_stall <= '0'; ID_EX_flush <= '0';
        end if;
    end process;

    --IF 
    PC_Next_Final <= IF_PC when PC_stall = '1' else IF_PC_Next;

    U_PC : reg_Pc port map (clk => clk, reset => reset, PC_In => PC_Next_Final, PC_Out => IF_PC);
    IF_PC_Plus4 <= std_logic_vector(unsigned(IF_PC) + 4);
    
   U_IMEM : instruction_memory port map (
            clock    => clk,
            address  => IF_PC(8 downto 2), 
            data_out => IF_Instr
        );

    -- REGISTRU IF/ID
    process(clk, reset)
    begin
        if reset = '1' then
            ID_Instr <= (others => '0'); ID_PC_Plus4 <= (others => '0');
        elsif rising_edge(clk) then
            if EX_PCSrc = '1' or ID_Jump = '1' then
                ID_Instr <= (others => '0');
            elsif IF_ID_stall = '0' then
                ID_Instr <= IF_Instr; ID_PC_Plus4 <= IF_PC_Plus4;
            end if;
        end if;
    end process;

    --ID 
    ID_rs <= ID_Instr(25 downto 21); ID_rt <= ID_Instr(20 downto 16); ID_rd <= ID_Instr(15 downto 11);
    
    U_CU : control_unit port map (clock =>clk,
        OP => ID_Instr(31 downto 26), Funct => ID_Instr(5 downto 0),
        MemtoReg => ID_MemtoReg, MemWrite => ID_MemWrite, Branch => ID_Branch,
        ALUControl => ID_ALUControl, ALUSrc => ID_ALUSrc, RegDst => ID_RegDst, RegWrite => ID_RegWrite, Jump => ID_Jump
    );

    U_REG_FIL : reg_file port map (
        clk => clk, rw => WB_RegWrite,
        ra1 => ID_rs, ra2 => ID_rt, wa => WB_WriteReg, wd => WB_Result,
        rd1 => ID_rd1, rd2 => ID_rd2
    );

    ID_SignImm <= std_logic_vector(resize(signed(ID_Instr(15 downto 0)), 32));

    -- REGISTRU ID/EX
    process(clk, reset)
    begin
        if reset = '1' then
            EX_RegWrite <= '0'; EX_MemtoReg <= '0'; EX_MemWrite <= '0'; EX_Branch <= '0';
            EX_ALUControl <= "000"; EX_ALUSrc <= '0'; EX_RegDst <= '0';
        elsif rising_edge(clk) then
            if ID_EX_flush = '1' or EX_PCSrc = '1' then
                EX_RegWrite <= '0'; EX_MemtoReg <= '0'; EX_MemWrite <= '0'; EX_Branch <= '0';
            else
                EX_RegWrite <= ID_RegWrite; EX_MemtoReg <= ID_MemtoReg; EX_MemWrite <= ID_MemWrite;
                EX_Branch <= ID_Branch; EX_ALUControl <= ID_ALUControl; EX_ALUSrc <= ID_ALUSrc; EX_RegDst <= ID_RegDst;
                EX_PC_Plus4 <= ID_PC_Plus4; EX_rd1 <= ID_rd1; EX_rd2 <= ID_rd2; EX_SignImm <= ID_SignImm;
                EX_rs <= ID_rs; EX_rt <= ID_rt; EX_rd <= ID_rd;
            end if;
        end if;
    end process;


    --Mux
    EX_ALUSrcA_Mux <= EX_rd1 when ForwardA = "00" else WB_Result when ForwardA = "01" else MEM_ALUResult;
    EX_ALUSrcB_Mux <= EX_rd2 when ForwardB = "00" else WB_Result when ForwardB = "01" else MEM_ALUResult;

    -- ALUSrc Mux
    EX_ALU_Final_B <= EX_ALUSrcB_Mux when EX_ALUSrc = '0' else EX_SignImm;

    U_ALU : ALU port map (
        A => EX_ALUSrcA_Mux, B => EX_ALU_Final_B, ALUOp => EX_ALUControl,
        Result => EX_ALUResult, Zero => EX_Zero
    );

    EX_WriteReg <= EX_rt when EX_RegDst = '0' else EX_rd;
    EX_PC_Branch <= std_logic_vector(unsigned(EX_PC_Plus4) + unsigned(EX_SignImm(29 downto 0) & "00"));
    EX_PCSrc <= EX_Branch and EX_Zero;

    -- Sincronizare Jump ?i Branch pentru IF_PC_Next
    IF_PC_Next <= (ID_PC_Plus4(31 downto 28) & ID_Instr(25 downto 0) & "00") when ID_Jump = '1' else
                  EX_PC_Branch when EX_PCSrc = '1' else
                  IF_PC_Plus4;

    -- REGISTRU EX/MEM
    process(clk, reset)
    begin
        if reset = '1' then
            MEM_RegWrite <= '0'; MEM_MemtoReg <= '0'; MEM_MemWrite <= '0';
        elsif rising_edge(clk) then
            MEM_RegWrite <= EX_RegWrite; MEM_MemtoReg <= EX_MemtoReg; MEM_MemWrite <= EX_MemWrite;
            MEM_ALUResult <= EX_ALUResult; MEM_WriteData <= EX_ALUSrcB_Mux; MEM_WriteReg <= EX_WriteReg;
        end if;
    end process;

    U_DMEM : data_memory port map (
        clock => clk, WE => MEM_MemWrite, WD => MEM_WriteData, A => MEM_ALUResult, RD => MEM_ReadData
    );
    -- REGISTRU MEM/WB
    process(clk, reset)
    begin
        if reset = '1' then
            WB_RegWrite <= '0'; WB_MemtoReg <= '0';
        elsif rising_edge(clk) then
            WB_RegWrite <= MEM_RegWrite; WB_MemtoReg <= MEM_MemtoReg;
            WB_ReadData <= MEM_ReadData; WB_ALUResult <= MEM_ALUResult; WB_WriteReg <= MEM_WriteReg;
        end if;
    end process;
    WB_Result <= WB_ALUResult when WB_MemtoReg = '0' else WB_ReadData;


process(clk, reset)
    begin
        if reset = '1' then
            led <= (others => '0');
        elsif rising_edge(clk) then
            if WB_RegWrite = '1' and WB_WriteReg /= "00000" then
                led <= WB_Result(15 downto 0);
            end if;
        end if;
    end process;

end Structural;