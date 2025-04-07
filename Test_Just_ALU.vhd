library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end alu_tb;

architecture behavior of alu_tb is
    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal waiting_flag: std_logic := '0';
    signal alu_in_1: std_logic_vector(15 downto 0);
    signal alu_in_2: std_logic_vector(15 downto 0);
    signal opcode: std_logic_vector(6 downto 0);
    signal shift: std_logic_vector(3 downto 0);
    signal alu_out: std_logic_vector(15 downto 0);
    signal z_flag: std_logic;
    signal n_flag: std_logic;
    signal o_flag: std_logic;

    component alu
        port(
            clk: in std_logic;
            waiting_flag: in std_logic;
            alu_in_1: in std_logic_vector(15 downto 0);
            alu_in_2: in std_logic_vector(15 downto 0);
            opcode: in std_logic_vector(6 downto 0);
            shift: in std_logic_vector(3 downto 0);
            rst: in std_logic;
            alu_out: out std_logic_vector(15 downto 0);
            z_flag: out std_logic;
            n_flag: out std_logic;
            o_flag: out std_logic
        );
    end component;

begin
    clk_process: process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    uut: alu port map(
        clk          => clk,
        waiting_flag => waiting_flag,
        alu_in_1     => alu_in_1,
        alu_in_2     => alu_in_2,
        opcode       => opcode,
        shift        => shift,
        rst          => rst,
        alu_out      => alu_out,
        z_flag       => z_flag,
        n_flag       => n_flag,
        o_flag       => o_flag
    );

    stimulus: process
    begin
        -- Reset
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        -- Step 1: ADD r3 = r2 + r1 (3 + 5 = 8)
        alu_in_1 <= x"0003";
        alu_in_2 <= x"0005";
        opcode <= "0000001"; -- ADD
        shift <= "0000";
        wait for 20 ns;

        -- Step 2: SHL r3 by 2 (8 << 2 = 32)
        alu_in_1 <= x"0008";
        opcode <= "0000101"; -- SHL
        shift <= "0010";
        wait for 20 ns;

        -- Step 3: MUL r2 = r1 * r3 (5 * 32 = 160)
        alu_in_1 <= x"0005";
        alu_in_2 <= x"0020";
        opcode <= "0000011"; -- MUL
        shift <= "0000";
        wait for 20 ns;

        wait;
    end process;
end behavior;
