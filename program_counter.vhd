library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
    port(
        clk: in std_logic; -- clock
        rst: in std_logic; -- rst 
        waiting: in std_logic; -- waiting flag
        enable: in std_logic; -- enable signal
        
        update_address: in std_logic_vector (15 downto 0); -- new address value
        program_counter: out std_logic_vector (15 downto 0)); --current program counter
end program_counter;

architecture behavioral of program_counter is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then -- check rst
                program_counter <= x"0000"; -- rst value
            else
                if(waiting = '1') then --Do we need to wait
                -- wait (do nothing and keep current prorgam counter)
                else 
                    if(enable = '0') then
                        program_counter <= std_logic_vector(signed(update_address) + 2); -- increment by 2
                    else
                        program_counter <= update_address; --go to new address
                    end if;
                end if;
            end if;
        end if;
    end process;
end behavioral;
