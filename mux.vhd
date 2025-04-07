library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mux is
    port(
        input_1: in std_logic_vector (15 downto 0);
        input_2: in std_logic_vector (15 downto 0);
        output_signal: out std_logic_vector (15 downto 0);
        
        select_switch: in std_logic);
end entity;

architecture behavioral of mux is
begin
    process(input_1, input_2, select_switch)
    begin
        if select_switch = '0' then
            output_signal <= input_1;
        else
            output_signal <= input_2;
        end if;
    end process;
            
end architecture;
