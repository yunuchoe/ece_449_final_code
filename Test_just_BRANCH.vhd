library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_tb is
end entity;

architecture testbench of branch_tb is
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';
    signal instruction_set: std_logic_vector(15 downto 0);
    signal negative_flag: std_logic := '0';
    signal zero_flag: std_logic := '0';
    signal register_7_in: std_logic_vector(15 downto 0) := (others => '0');
    signal register_7_out: std_logic_vector(15 downto 0);
    signal program_counter_out: std_logic_vector(15 downto 0);
    signal opcode: std_logic_vector(6 downto 0);
    signal register_a_index: std_logic_vector(2 downto 0);
    signal register_a_value: std_logic_vector(15 downto 0);
    signal disp_l: std_logic_vector(8 downto 0);
    signal disp_s: std_logic_vector(5 downto 0);

begin
    uut: entity work.branch
        port map (
            clk => clk,
            rst => rst,
            instruction_set => instruction_set,
            negative_flag => negative_flag,
            zero_flag => zero_flag,
            opcode => opcode,
            register_a_index => register_a_index,
            register_a_value => register_a_value,
            disp_l => disp_l,
            disp_s => disp_s,
            register_7_in => register_7_in,
            register_7_out => register_7_out,
            program_counter_out => program_counter_out
        );
    
    -- Clock
    process
    begin
        while true loop
            clk <= '0'; wait for 10 ns;
            clk <= '1'; wait for 10 ns;
        end loop;
    end process;
    
    process
    begin
        -- reset to srart
        rst <= '1';
        wait until rising_edge(clk);
        rst <= '0';
        
        register_a_value <= "0000000000000010"; -- set as 2

         -- TEST 1

        -- 64 BRR
        -- pc = 0 + 2*2 = 4
            wait until rising_edge(clk);
            instruction_set <= "1000000000000010"; -- BBR 2
        
       
        -- 65 BRR N
        -- pc = 4 + 2*2 = 8
            --wait until rising_edge(clk);
            --negative_flag <= '1'; -- negative
            --instruction_set <= "1000001000000010"; -- BBR 2
        
        -- 66 BRR Z
        -- pc = 8 + 2*2 = 12
            --wait until rising_edge(clk);
            --zero_flag <= '1'; -- negative
            --instruction_set <= "1000010000000010"; -- BBR 2
            
        -- TEST 2
        
        -- 67 BR
        -- ra = 2
        -- disp.s = 2
        -- thus pc = 2 + 2*2 = 6
            --wait until rising_edge(clk);
            --instruction_set <= "1000011000000010"; -- BR 2
        
        -- 68 BR N
        -- ra = 2
        -- disp.s = 2
        -- thus pc = 2 + 2*2 = 6
            --wait until rising_edge(clk);
            --negative_flag <= '1'; -- negative
            --instruction_set <= "1000100000000010"; -- BR 2
        
        -- 69 BR Z
        -- ra = 2
        -- disp.s = 2
        -- thus pc = 2 + 2*2 = 6
            --wait until rising_edge(clk);
            --zero_flag <= '1'; -- negative
            --instruction_set <= "1000101000000010"; -- BR 2
        
        -- TEST 3
        
        -- 70 BR sub
        --r7 = 0 + 2 = 2
        -- pc = ra + 2*2 = 6
            wait until rising_edge(clk);
            zero_flag <= '1'; -- negative
            instruction_set <= "1000110000000010"; -- BR 2
        
        -- 71 return
        -- pc = r7 = 0
            wait until rising_edge(clk);
            zero_flag <= '1'; -- negative
            instruction_set <= "1000111000000010"; -- return
        

        wait until rising_edge(clk);
    end process;
end testbench;
