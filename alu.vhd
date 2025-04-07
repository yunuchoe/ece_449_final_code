library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port(
        rst: in std_logic;
        clk: in std_logic;
        
        opcode: in std_logic_vector (6 downto 0);
        alu_in_1: in std_logic_vector (15 downto 0);
        alu_in_2: in std_logic_vector (15 downto 0);        
        shift_by: in std_logic_vector (3 downto 0);
        
        z_flag: out std_logic := '0';
        n_flag: out std_logic := '0';
        o_flag: out std_logic := '0';
        alu_out: out std_logic_vector (15 downto 0));
end alu;

architecture behavioral of alu is
    -- signals
    signal add_output: std_logic_vector(15 downto 0);
    signal add_overflow_bit: std_logic;

    signal subtract_output: std_logic_vector(15 downto 0);
    signal subtract_overflow_bit: std_logic;

    signal multiply_output: std_logic_vector(15 downto 0);
    signal multiply_overflow_bit: std_logic;

    signal nand_output: std_logic_vector(15 downto 0);

    signal shift_left_ouput: std_logic_vector(15 downto 0);
    signal shift_right_ouput: std_logic_vector(15 downto 0);

    --components
    component adder is
        port(
            register_a: out std_logic_vector (15 downto 0);
            register_b: in std_logic_vector (15 downto 0);
            register_c: in std_logic_vector (15 downto 0);
            overflow: out std_logic);
    end component;
    
    component subtractor is
        port(
            register_a: out std_logic_vector (15 downto 0);
            register_b: in std_logic_vector (15 downto 0);
            register_c: in std_logic_vector (15 downto 0);
            overflow: out std_logic);
    end component;
    
    component multiplier is
        port(
            register_a: out std_logic_vector (15 downto 0);
            register_b: in std_logic_vector (15 downto 0);
            register_c: in std_logic_vector (15 downto 0);
            overflow: out std_logic);
    end component;
    
    component left_shifter is
        port(
            shift_by: in std_logic_vector (3 downto 0);
            register_in: in std_logic_vector (15 downto 0);
            register_out: out std_logic_vector (15 downto 0));
    end component;
    
    component right_shifter is
        port(
            shift_by: in std_logic_vector (3 downto 0);
            register_in: in std_logic_vector (15 downto 0);
            register_out: out std_logic_vector (15 downto 0));
    end component;

begin
    add: adder port map(
        register_b => alu_in_1(15 downto 0),  
        register_c => alu_in_2(15 downto 0), 
        register_a => add_output, 
        overflow => add_overflow_bit);
           
    subtract: subtractor port map(
        register_b => alu_in_1(15 downto 0), 
        register_c => alu_in_2(15 downto 0), 
        register_a => subtract_output, 
         overflow => subtract_overflow_bit);
         
    multiply: multiplier port map(
        register_b => alu_in_1(15 downto 0), 
        register_c => alu_in_2(15 downto 0), 
        register_a => multiply_output, 
        overflow => multiply_overflow_bit);
        
    shiftleft: left_shifter port map(
        shift_by => shift_by, 
        register_in => alu_in_1(15 downto 0), 
        register_out => shift_left_ouput);
        
    shiftright: right_shifter port map(
        shift_by => shift_by, 
        register_in => alu_in_1(15 downto 0), 
        register_out => shift_right_ouput);
        
    -- processes
    process (clk)
    begin
        if (clk='0' and clk'event) then -- important that this happens on falling edge
            if rst = '1' then
                alu_out <= "0000000000000000"; --set to 0
                z_flag <= '0'; -- clear all flags on rst
                n_flag <= '0';
                o_flag <= '0';
            else
                -- still clear 
                alu_out <= "0000000000000000"; --set to 0
                z_flag <= '0'; -- clear all flags on rst
                n_flag <= '0';
                o_flag <= '0';
    
                if opcode = "0000001" then -- ADD
                    alu_out <= add_output;
                    o_flag  <= add_overflow_bit;
    
                    if add_output = "0000000000000000" then
                        z_flag <= '1';
                    else
                        z_flag <= '0';  
                    end if;
                        
                elsif opcode = "0000010" then  -- SUB
                    alu_out <= subtract_output;
                    o_flag  <= subtract_overflow_bit;
    
                    if subtract_output = "0000000000000000" then
                        z_flag <= '1';
                     else
                         z_flag <= '0'; 
                    end if;
                    n_flag <= subtract_output(15);--15 bit is n flag
        
                elsif opcode = "0000011" then  -- MUL
                    alu_out <= multiply_output;
                    o_flag  <= multiply_overflow_bit;
    
                    if multiply_output = "0000000000000000" then
                        z_flag <= '1';
                    else
                        z_flag <= '0';
                    end if;
                    n_flag <= multiply_output(15);--15 bit is n flag
    
                elsif opcode = "0000100" then  -- NAND
                    alu_out <= not (alu_in_1 and alu_in_2);
                    --no flags for nand
    
                elsif opcode = "0000101" then  -- SHL
                    alu_out <= shift_left_ouput;
                    o_flag  <= '0';
                    if shift_left_ouput = "0000000000000000" then
                        z_flag <= '1';
                    else
                        z_flag <= '0';
                    end if;
                    n_flag <= shift_left_ouput(15);
    
                elsif opcode = "0000110" then  -- SHR
                    alu_out <= shift_right_ouput;
                    o_flag  <= '0';

                    if shift_right_ouput = ("0000000000000000") then
                        z_flag <= '1';
                    else
                        z_flag <= '0';
                    end if;
                    n_flag <= shift_right_ouput(15);
                    
                elsif opcode = "0000111" then  -- Test
                    --z-flag
                    if alu_in_1 = "0000000000000000" then
                        z_flag <= '1';
                    else
                        z_flag <= '0';
                    end if;
            
                    --n-flag
                    if alu_in_1(15) = '1' then
                        n_flag <= '1';
                    else
                        n_flag <= '0';
                    end if;
                else -- none
                    alu_out <= "0000000000000000"; 
                end if;
            end if;
        end if;
    end process;
end behavioral;


-- adder
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
    port(
        register_a: out std_logic_vector (15 downto 0);
        register_b: in std_logic_vector (15 downto 0);
        register_c: in std_logic_vector (15 downto 0);
        overflow: out std_logic);
end adder;

architecture behavioral of adder is
    signal result: signed(16 downto 0); --17bit to catch overflow
begin
    process(register_b, register_c, result)
    begin
        result <= resize(signed(register_b), 17) + resize(signed(register_c), 17); -- add

        if register_b(15) = register_c(15) then -- check overflow
            overflow <= register_b(15) XOR result(16); -- if disagree, overlfow
        end if;

        register_a <= std_logic_vector(result(15 downto 0)); -- update (16 bit only)
    end process;
end behavioral;

-- sub
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity subtractor is
    port(
        register_a: out std_logic_vector (15 downto 0);
        register_b: in std_logic_vector (15 downto 0);
        register_c: in std_logic_vector (15 downto 0);
        overflow: out std_logic);
end subtractor;

architecture behavioral of subtractor is
    signal result: signed(16 downto 0);
begin
    process (register_b, register_c, result)
    begin
        result <= resize(signed(register_b), 17) - resize(signed(register_c), 17); -- sub
        
        overflow <= '0';
        if (register_b(15) /= register_c(15)) then -- first condition (msb of both operands must not equal)
            if (register_c(15) = result(16)) then -- second conditon (msb of subtract value is same as reuslts msb)
                overflow <= '1';
            end if;
        end if;
        register_a <= std_logic_vector(result(15 downto 0)); -- update (16 bit only)
    end process;
end behavioral;

-- multiplier
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
    port(
        register_a: out std_logic_vector (15 downto 0);
        register_b: in std_logic_vector (15 downto 0);
        register_c: in std_logic_vector (15 downto 0);
        overflow: out std_logic);
end multiplier;

architecture behavioral of multiplier is

begin
    process (register_b, register_c)
        variable temp: signed(31 downto 0); -- 32 bit (16x16)
    begin
    
        temp := signed(register_b) * signed(register_c);
        
        overflow <= '0';
        if (register_b(15) = register_c(15)) then -- first condition
            if (temp(31) /= register_b(15)) then -- second condition
                overflow <= '1';
            end if;
        end if;
        
        register_a <=  std_logic_vector(temp(15 downto 0));
    end process;
end behavioral;


-- shift_by left
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity left_shifter is
    port(
        shift_by: in std_logic_vector (3 downto 0);
        register_in: in std_logic_vector (15 downto 0);
        register_out: out std_logic_vector (15 downto 0));
end left_shifter;

architecture behavioral of left_shifter is
    
begin
    process (shift_by, register_in)
        variable shift_result_1: std_logic_vector(15 downto 0);
        variable shift_result_2: std_logic_vector(15 downto 0);
        variable shift_result_3: std_logic_vector(15 downto 0);
        variable shift_result_4: std_logic_vector(15 downto 0);
    begin

        -- 0001
        if shift_by = "0001" then -- shift_by by 2^0=1
            shift_result_1 := (register_in((15-1) downto 0) & "0");
        else
            shift_result_1 := register_in; -- carry
        end if;

        -- 0010
        if shift_by = "0010" then -- shift_by by 2^1 = 2
            shift_result_2 := (shift_result_1((15-2) downto 0) & "00");
        else
            shift_result_2 := shift_result_1; -- carry
        end if;
        
        -- 0100
        if shift_by = "0100" then -- shift_by by 2^2 = 4
            shift_result_3 := (shift_result_2((15-4) downto 0) & "0000");
        else
            shift_result_3 := shift_result_2; -- carry
        end if;
        
        -- 1000
        if shift_by = "1000" then -- shift_by by 2^3 = 8
            shift_result_4 := (shift_result_3((15-8) downto 0) & "00000000");
        else
            shift_result_4 := shift_result_3;
        end if;
            
        register_out <= shift_result_4; -- update
    end process;
end behavioral;

-- shift_by right
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity right_shifter is
    port(
        shift_by: in std_logic_vector (3 downto 0);
        register_in: in std_logic_vector (15 downto 0);
        register_out: out std_logic_vector (15 downto 0));
end right_shifter;

architecture behavioral of right_shifter is
    
begin
    process (shift_by, register_in)
        variable shift_result_1: std_logic_vector(15 downto 0);
        variable shift_result_2: std_logic_vector(15 downto 0);
        variable shift_result_3: std_logic_vector(15 downto 0);
        variable shift_result_4: std_logic_vector(15 downto 0);
    begin

        -- smsame style as shift_by left but other way around
            
        if shift_by = "0001" then
            shift_result_1 := ("0" & register_in(15 downto 1));
        else
            shift_result_1 := register_in;
        end if;

        if shift_by = "0010" then
            shift_result_2 := ("00" & shift_result_1(15 downto 2));
        else
            shift_result_2 := shift_result_1;
        end if;
        
        if shift_by = "0100" then
            shift_result_3 := ("0000" & shift_result_2(15 downto 4));
        else
            shift_result_3 := shift_result_2;
        end if;
        
        if shift_by = "1000" then
            shift_result_4 := ("00000000" & shift_result_3(15 downto 8));
        else
            shift_result_4 := shift_result_3;
        end if;
            
        register_out <= shift_result_4;
    end process;
end behavioral;
