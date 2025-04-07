library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
    port(
        rst : in std_logic; 
        clk: in std_logic;
        
        --read signals
        rd_index1: in std_logic_vector(2 downto 0); 
        rd_index2: in std_logic_vector(2 downto 0); 
        
        rd_data1: out std_logic_vector(15 downto 0); 
        rd_data2: out std_logic_vector(15 downto 0);
        
        --write signals
        wr_index: in std_logic_vector(2 downto 0); 
        wr_data: in std_logic_vector(15 downto 0); 
        wr_enable: in std_logic);
end register_file;

architecture behavioral of register_file is
    type reg_array is array (0 to 7) of std_logic_vector(15 downto 0);
    signal reg_file : reg_array;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                for i in 0 to 7 loop
                    reg_file(i)<= (others => '0'); 
                end loop;
            elsif wr_enable = '1' then
                case wr_index is
                    when "000" => reg_file(0) <= wr_data;
                    when "001" => reg_file(1) <= wr_data;
                    when "010" => reg_file(2) <= wr_data;
                    when "011" => reg_file(3) <= wr_data;
                    when "100" => reg_file(4) <= wr_data;
                    when "101" => reg_file(5) <= wr_data;
                    when "110" => reg_file(6) <= wr_data;
                    when "111" => reg_file(7) <= wr_data;
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    -- data 1
    process(reg_file, rd_index1)
    begin
        case rd_index1 is
            when "000" => rd_data1 <= reg_file(0);
            when "001" => rd_data1 <= reg_file(1);
            when "010" => rd_data1 <= reg_file(2);
            when "011" => rd_data1 <= reg_file(3);
            when "100" => rd_data1 <= reg_file(4);
            when "101" => rd_data1 <= reg_file(5);
            when "110" => rd_data1 <= reg_file(6);
            when others => rd_data1 <= reg_file(7);
        end case;
    end process;

    -- data 2
    process(reg_file, rd_index2)
    begin
        case rd_index2 is
            when "000" => rd_data2 <= reg_file(0);
            when "001" => rd_data2 <= reg_file(1);
            when "010" => rd_data2 <= reg_file(2);
            when "011" => rd_data2 <= reg_file(3);
            when "100" => rd_data2 <= reg_file(4);
            when "101" => rd_data2 <= reg_file(5);
            when "110" => rd_data2 <= reg_file(6);
            when others => rd_data2 <= reg_file(7);
        end case;
    end process;
end behavioral;
