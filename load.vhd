library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity load is
    port(
        clk: in std_logic;
        rst: in std_logic;
        
        instruction_set: in std_logic_vector (15 downto 0);
        
        destination_register_index: in std_logic_vector (2 downto 0); -- destination
        source_register_index: in std_logic_vector (2 downto 0); -- source
        destination_register_value: out std_logic_vector (15 downto 0);
        source_register_value: in std_logic_vector (15 downto 0);
        
        register_7: out std_logic_vector(15 downto 0); -- placeholder for toy example
        
        upper_lower_in: in std_logic;
        immediate_value_in: in std_logic_vector(7 downto 0)
    );
end load;

architecture behavioral of load is

    signal opcode: std_logic_vector (6 downto 0); 
    
    signal in_destination_register_index: std_logic_vector (2 downto 0);
    signal in_source_register_index: std_logic_vector (2 downto 0);
    signal in_destination_register_value: std_logic_vector (15 downto 0);
    signal temp_register_7: std_logic_vector(15 downto 0) := (others => '0');

begin

    process (clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then -- reset
                opcode <= (others => '0'); 
                in_destination_register_index <= (others => '0');
                in_source_register_index <= (others => '0');
                in_destination_register_value <= (others => '0');
                temp_register_7 <= (others => '0');
            else
                opcode <= instruction_set(15 downto 9);
                in_destination_register_index <= instruction_set(8 downto 6);
                in_source_register_index <= instruction_set(5 downto 3);
                
                if opcode = "0010000" then  -- LOAD (16)
                    --destination_register_value <= source_register_index; -- put memory locaation into desintation
                    
                elsif opcode = "0010001" then  -- STORE (17)
                    --destination_register_index <= source_register_value; -- make memory location equal to source;
                    
                elsif opcode = "0010010" then  -- LOADIMM (18)
                    -- normally would read r7  and modify register file
                    if upper_lower_in = '1' then -- most sig bits (15-8)
                        temp_register_7(15 downto 8) <= immediate_value_in;
                    else -- least sig bits (7-0)
                        temp_register_7(7 downto 0) <= immediate_value_in;
                    end if;

                elsif  opcode = "0010011" then -- MOV (19)
                    in_destination_register_value <= source_register_value; -- dest <= source
                end if;
            end if;
        end if;
    end process;
    -- update
    register_7 <= temp_register_7;
    destination_register_value <= in_destination_register_value;
end behavioral;
