library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity load_tb is
end load_tb;

architecture behavioral of load_tb is

    -- compoenent
    component load
        port(
            clk: in std_logic;
            rst: in std_logic;
            instruction_set: in std_logic_vector(15 downto 0);
            
            destination_register_index: in std_logic_vector (2 downto 0); -- destination
            source_register_index: in std_logic_vector (2 downto 0); -- source
            destination_register_value: out std_logic_vector (15 downto 0);
            source_register_value: in std_logic_vector (15 downto 0);
            
            register_7: out std_logic_vector(15 downto 0);
            upper_lower_in: in std_logic;
            immediate_value_in: in std_logic_vector(7 downto 0));
    end component;
    
    -- signals
    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal instruction_set: std_logic_vector(15 downto 0) := (others => '0');
    signal register_7: std_logic_vector(15 downto 0);
    
    signal destination_register_index: std_logic_vector (2 downto 0) := (others => '0');-- destination
    signal source_register_index: std_logic_vector (2 downto 0) := (others => '0'); -- source
    signal destination_register_value: std_logic_vector (15 downto 0) := (others => '0');
    signal source_register_value: std_logic_vector (15 downto 0) := (others => '0');

    signal upper_lower_in: std_logic := '0';
    signal immediate_value_in: std_logic_vector(7 downto 0) := (others => '0');

begin

    uut: load
        port map (
            clk => clk,
            rst => rst,
            instruction_set => instruction_set,
            destination_register_index => destination_register_index,
            source_register_index => source_register_index,
            destination_register_value => destination_register_value,
            source_register_value => source_register_value,
            register_7 => register_7,
            upper_lower_in => upper_lower_in,
            immediate_value_in => immediate_value_in);

    -- clock 
    process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Test
    process
    begin
        rst <= '1';
        wait for 40 ns;
        rst <= '0';

        -- LOADIMM (18)
        instruction_set <= "0010010000000000"; -- LOADIMM
        immediate_value_in <= "00001000"; -- should be x0800
        upper_lower_in <= '1';
        wait for 40 ns;

        --instruction_set <= "0010010000000000"; -- LOADIMM
        upper_lower_in <= '0';
        immediate_value_in <= "00000001"; -- should be x0801
        wait for 40 ns;
        
       --MOV (19)
        source_register_value <= "0000000000000010"; -- 2
        -- dest should also be 2
        instruction_set <= "0010011000000000"; -- MOV
        wait for 40 ns;

        wait for 40 ns;

        wait;
    end process;
end behavioral;
