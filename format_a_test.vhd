library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_controller_sub is
end test_controller_sub;

architecture behavioural of test_controller_sub is

    component format_a
        port (
            rst: in std_logic;
            clk: in std_logic;
            reg_1_output_test: out std_logic_vector(15 downto 0);
            reg_2_output_test: out std_logic_vector(15 downto 0);
            reg_3_output_test: out std_logic_vector(15 downto 0);
            reg_1_index_test: out std_logic_vector(2 downto 0);
            reg_2_index_test: out std_logic_vector(2 downto 0);
            reg_3_index_test: out std_logic_vector(2 downto 0);
            instruction_set: in std_logic_vector(15 downto 0);
            alu_result: out std_logic_vector(15 downto 0);
            program_counter: out std_logic_vector(15 downto 0)
        );
    end component;

    signal rst: std_logic := '0';
    signal clk: std_logic := '0';
    signal reg_1_output_test: std_logic_vector(15 downto 0);
    signal reg_2_output_test: std_logic_vector(15 downto 0);
    signal reg_3_output_test: std_logic_vector(15 downto 0);
    signal reg_1_index_test: std_logic_vector(2 downto 0);
    signal reg_2_index_test: std_logic_vector(2 downto 0);
    signal reg_3_index_test: std_logic_vector(2 downto 0);
    signal instruction_set: std_logic_vector(15 downto 0) := (others => '0');
    signal program_counter: std_logic_vector(15 downto 0);
    signal alu_result: std_logic_vector(15 downto 0);
    

begin
    uut : format_a
        port map (
            rst => rst,
            clk => clk,
            reg_1_output_test => reg_1_output_test,
            reg_2_output_test => reg_2_output_test,
            reg_3_output_test => reg_3_output_test,
            reg_1_index_test => reg_1_index_test,
            reg_2_index_test => reg_2_index_test,
            reg_3_index_test => reg_3_index_test,
            instruction_set => instruction_set,
            alu_result => alu_result,
            program_counter => program_counter
        );
        
    -- clock
    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for 10 ns;
            clk <= '1'; wait for 10 ns;
        end loop;
    end process;

    stimulus : process
    begin
        -- Reset
        rst <= '1';
        instruction_set <= (others => '0'); -- NOP
        wait until rising_edge(clk);
        rst <= '0';

        -- IN r1 = 03
        instruction_set <= "0100001001000000"; wait until rising_edge(clk);

        -- IN r2 = 05
        instruction_set <= "0100001010000000"; wait until rising_edge(clk);

        -- NOPs for pipelining
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        
        -- ADD r3 = r2 + r1 = 8
        instruction_set <= "0000001011010001"; wait until rising_edge(clk);

        -- NOPs
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        
        -- SHL r3, 2 ? 8 << 2 = 32
        instruction_set <= "0000101011000010"; wait until rising_edge(clk);

        -- NOPs
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);

        -- MUL r2 = r1 * r3 = 3 * 32 = 96
        instruction_set <= "0000011010001011"; wait until rising_edge(clk);

        -- NOPs
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);

        -- OUT r2 ? should output 96
        instruction_set <= "0100000010000000"; wait until rising_edge(clk);

        -- Final NOPs
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);
        instruction_set <= "0000000000000000"; wait until rising_edge(clk);

        wait;
    end process;
end behavioural;
