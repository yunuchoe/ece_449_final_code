library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch is
    port(
        clk: in std_logic;
        rst: in std_logic;
        
        instruction_set: in std_logic_vector (15 downto 0);

        negative_flag: in std_logic := '0';
        zero_flag: in std_logic := '0';

        opcode: out std_logic_vector (6 downto 0); -- op code
        register_a_index: in std_logic_vector (2 downto 0); -- not needed for this toy example since we arent suing register file
        register_a_value: in std_logic_vector (15 downto 0);

        disp_l: out std_logic_vector (8 downto 0); -- l branch value
        disp_s: out std_logic_vector (5 downto 0); -- s branch value

        register_7_in: in std_logic_vector(15 downto 0); 
        register_7_out: out std_logic_vector(15 downto 0);

        program_counter_out: out std_logic_vector (15 downto 0));
end branch;

architecture behavioral of branch is
    -- Internal signals for opcode and registers
    signal opcode_signal: std_logic_vector (6 downto 0);
    --signal register_a_index_signal: std_logic_vector (2 downto 0);
    --signal register_a_value_signal: std_logic_vector (15 downto 0);

    signal disp_l_signal: signed (8 downto 0);
    signal disp_s_signal: signed (5 downto 0);
    
    signal sig_register_7_out: std_logic_vector(15 downto 0);
    
    signal program_counter_current: signed (15 downto 0);

begin
    process (clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset all values
                opcode_signal <= (others => '0'); 
                --register_a_index_signal <= (others => '0');
                --register_a_value_signal <= (others => '0');
                register_7_out <= (others => '0');
                program_counter_current <= (others => '0');  -- Initialize program counter
                program_counter_out <= (others => '0');
            else
                -- Load values
                opcode_signal <= instruction_set(15 downto 9);

                -- Assign internal values to output ports
                opcode <= opcode_signal;
                --register_a_index <= register_a_index_signal;
                --register_a_value <= register_a_value_signal;


                -- Opcode-based operations
                if opcode_signal = "1000000" then  -- BRR (64)
                    disp_l_signal <= signed(instruction_set(8 downto 0));
                    program_counter_current <= signed(resize(signed(program_counter_current), 16) + resize(2 * (signed(disp_l_signal)), 16));

                elsif opcode_signal = "1000001" then  -- BRR N (65)
                    disp_l_signal <= signed(instruction_set(8 downto 0));
                    if negative_flag = '1' then
                        program_counter_current <= (resize(signed(program_counter_current), 16) + resize(2 * (signed(disp_l_signal)), 16));

                    else
                        program_counter_current <= (resize(signed(program_counter_current), 16) + to_signed(2, 16));
                    end if;

                elsif opcode_signal = "1000010" then  -- BRR Z (66)
                    disp_l_signal <= signed(instruction_set(8 downto 0));
                    if zero_flag = '1' then
                        program_counter_current <= (resize(signed(program_counter_current), 16) + resize(2 * (signed(disp_l_signal)), 16));

                    else
                        program_counter_current <= (resize(signed(program_counter_current), 16) + to_signed(2, 16));
                    end if;

                elsif opcode_signal = "1000011" then  -- BR (67)
                    --register_a_index_signal <= instruction_set(8 downto 6);
                    disp_s_signal <= signed(instruction_set(5 downto 0));
                    program_counter_current <= (resize(signed(register_a_value), 16) + resize(2 * (signed(disp_s_signal)), 16));

                elsif opcode_signal = "1000100" then  -- BR N (68)
                    --register_a_index_signal <= instruction_set(8 downto 6);
                    disp_s_signal <= signed(instruction_set(5 downto 0));
                    if negative_flag = '1' then
                        program_counter_current <= (resize(signed(register_a_value), 16) + resize(2 * (signed(disp_s_signal)), 16));
                    else
                        program_counter_current <= (resize(signed(program_counter_current), 16) + to_signed(2, 16));
                    end if;

                elsif opcode_signal = "1000101" then  -- BR Z (69)
                    --register_a_index_signal <= instruction_set(8 downto 6);
                    disp_s_signal <= signed(instruction_set(5 downto 0));
                    if zero_flag = '1' then
                        program_counter_current <= (resize(signed(register_a_value), 16) + resize(2 * (signed(disp_s_signal)), 16));
                    else
                        program_counter_current <= (resize(signed(program_counter_current), 16) + to_signed(2, 16));
                    end if;

                elsif opcode_signal = "1000110" then  -- BR SUB (70)
                    --register_a_index_signal <= instruction_set(8 downto 6);
                    disp_s_signal <= signed(instruction_set(5 downto 0));
                    register_7_out <= std_logic_vector(unsigned(program_counter_current) + 2); -- update output
                    sig_register_7_out <= std_logic_vector(unsigned(program_counter_current)); -- update temp var
                    program_counter_current <= (resize(signed(register_a_value), 16) + resize(2 * (signed(disp_s_signal)), 16));

                elsif opcode_signal = "1000111" then  -- Return (71)
                    program_counter_current <= resize(signed(sig_register_7_out), 16);  -- assign directly
                end if;
                disp_l <= std_logic_vector(disp_l_signal);
                disp_s <= std_logic_vector(disp_s_signal);
            end if;
            -- Output the current program counter
            program_counter_out <= std_logic_vector(resize(signed(program_counter_current), 16));
        end if;
    end process;
end behavioral;
