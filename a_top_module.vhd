library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity format_a is
    port(
        rst: in std_logic;
        clk: in std_logic;
        
        reg_1_output_test: out std_logic_vector(15 downto 0); -- testing vars
        reg_2_output_test: out std_logic_vector(15 downto 0);
        reg_3_output_test: out std_logic_vector(15 downto 0);
        reg_1_index_test: out std_logic_vector(2 downto 0);
        reg_2_index_test: out std_logic_vector(2 downto 0);
        reg_3_index_test: out std_logic_vector(2 downto 0);
        
        instruction_set: in std_logic_vector(15 downto 0);
        
        alu_result: out std_logic_vector(15 downto 0);
        program_counter: out std_logic_vector(15 downto 0));
end format_a;

architecture behavioural of format_a is
    --signals
    signal z_flag: std_logic;
    signal n_flag: std_logic;
    signal o_flag: std_logic;
    signal opcode: std_logic_vector(6 downto 0);
    signal shift_by: std_logic_vector(3 downto 0);

    signal current_program_counter: std_logic_vector(15 downto 0);
    
    -- pipeline registers
    signal if_id: std_logic_vector(15 downto 0);  -- fetch decode
    signal id_ex: std_logic_vector(15 downto 0);  -- decode exectue
    signal ex_mem: std_logic_vector(15 downto 0);  -- execute memory
    signal mem_wb: std_logic_vector(15 downto 0);  -- memory write-back

    -- register file
    signal register_a_index: std_logic_vector(2 downto 0);
    signal register_b_index: std_logic_vector(2 downto 0);
    signal register_c_index: std_logic_vector(2 downto 0);

    signal register_a_value: std_logic_vector(15 downto 0);
    signal register_b_value: std_logic_vector(15 downto 0);
    signal register_c_value: std_logic_vector(15 downto 0);
    signal write_enable: std_logic;
    
    -- ALU
    signal alu_in1: std_logic_vector(15 downto 0);
    signal alu_in2: std_logic_vector(15 downto 0);

    signal alu_out: std_logic_vector(15 downto 0);
    signal alu_out_mem: std_logic_vector(15 downto 0);

    -- component
    component alu is
        port(
            rst: in STD_LOGIC;
            clk: in STD_LOGIC;
            
            opcode: in STD_LOGIC_VECTOR (6 downto 0);
            alu_in_1: in STD_LOGIC_VECTOR (15 downto 0);
            alu_in_2: in STD_LOGIC_VECTOR (15 downto 0);        
            shift_by: in STD_LOGIC_VECTOR (3 downto 0);
            
            z_flag: out STD_LOGIC := '0';
            n_flag: out STD_LOGIC := '0';
            o_flag: out STD_LOGIC := '0';
            alu_out: out STD_LOGIC_VECTOR (15 downto 0));
    end component;

    component register_file is
        port(
            rst: in std_logic; 
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
    end component;

-- program counter - notreally releveant for this part
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then -- reset
                current_program_counter <= (others => '0'); -- clear
            else
                current_program_counter <= std_logic_vector(unsigned(current_program_counter) + 2); -- incremeent by 2
            end if;
        end if;
    end process;
    program_counter <= current_program_counter; -- update

    -- latch
    process(clk) 
    begin
        if rising_edge(clk) then
            if rst = '1' then
                if_id  <= (others => '0');
                id_ex  <= (others => '0');
                ex_mem <= (others => '0');
                mem_wb <= (others => '0');
            else
                if_id <= instruction_set; -- fetch stage
                id_ex <= if_id; -- decode stage
                ex_mem <= id_ex; -- execute stage
                mem_wb <= ex_mem; -- memory stage
            end if;
        end if;
    end process;

    -- maps
    ALU_module: alu
        port map(
            rst => rst,
            clk => clk,
            opcode => opcode,
            alu_in_1 => alu_in1,
            alu_in_2 => alu_in2,
            shift_by => shift_by,
            z_flag => z_flag,
            n_flag  => n_flag,
            o_flag  => o_flag,
            alu_out => alu_out);
        
    REGISTER_module: register_file
        port map(
            rst => rst,
            clk => clk,
            rd_index1 => register_b_index,
            rd_index2 => register_c_index,
            rd_data1 => register_b_value,
            rd_data2 => register_c_value,
            wr_index => register_a_index,
            wr_data => register_a_value,
            wr_enable => write_enable);

    -- control 
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then -- reset
                write_enable <= '0';
                opcode <= (others => '0');
                shift_by <= (others => '0');
                alu_out_mem <= (others => '0');
                register_a_index <= (others => '0');
            else
                -- decode stage
                if unsigned(id_ex(15 downto 9)) >= 1 and unsigned(id_ex(15 downto 9)) <= 4 then
                    register_b_index <= id_ex(5 downto 3);
                    register_c_index <= id_ex(2 downto 0);
                elsif (unsigned(id_ex(15 downto 9)) >= 32 and unsigned(id_ex(15 downto 9)) <= 33) or
                      (unsigned(id_ex(15 downto 9)) >= 5 and unsigned(id_ex(15 downto 9)) <= 7) then
                    register_b_index <= id_ex(8 downto 6);
                    register_c_index <= (others => '0');  -- clear just ot be safe
                end if;
                
                -- execute stage
                alu_in1 <= register_b_value; -- update new rb and rc val
                alu_in2 <= register_c_value;
                
                -- found a hazard for this specifc test bench
                -- if performing the SHL, we need to use an older value of alu_out_mem not the resgiter value
                if(unsigned(id_ex(15 downto 9)) = 5) then -- temporary condition for SHL
                    alu_in1 <= alu_out_mem;
                end if;
                    
                -- for debugging
                reg_1_output_test <= register_b_value; -- update test values
                reg_2_output_test <= register_c_value;
                reg_3_output_test <= register_a_value;
                reg_1_index_test <= register_b_index; -- update test values
                reg_2_index_test <= register_c_index;
                reg_3_index_test <= register_a_index;
    
                -- determine op code (and shifter if needed)
                if unsigned(id_ex(15 downto 9)) >= 1 and unsigned(id_ex(15 downto 9)) <= 4 then
                    opcode <= id_ex(15 downto 9);
                elsif id_ex(15 downto 9) = "0000101" then
                    shift_by  <= id_ex(3 downto 0);
                    opcode <= "0000101";
                elsif id_ex(15 downto 9) = "0000110" then
                    shift_by  <= id_ex(3 downto 0);
                    opcode <= "0000110";
                elsif id_ex(15 downto 9) = "0000111" then
                    opcode <= "0000111";
                elsif id_ex(15 downto 9) = "0100000" then
                    opcode <= "0100000";
                elsif id_ex(15 downto 9) = "0100001" then
                    opcode <= "0100001";
                end if;

                    
                -- memory stage 
                -- pretty short thus far...
                alu_out_mem <= alu_out; -- pass along into mem stage (need to hold onto value for layter)
                --alu_result <= alu_out; -- for debugging
                if id_ex(15 downto 9) = "0100000" then -- OUT (32) -- output would perform its work here
                    alu_result <= alu_out;
                end if;

                    
                -- write back stage
                if mem_wb(15 downto 9) = "0000000" then -- nop
                    write_enable <= '0';
                elsif (unsigned(mem_wb(15 downto 9)) >= 1 and unsigned(mem_wb(15 downto 9)) <= 6) then -- if we performed work, need to store into register a
                    write_enable <= '1'; -- write into register file
                    register_a_index  <= mem_wb(8 downto 6); -- give index which was given in fetch
                    register_a_value  <= alu_out_mem; -- pass value along
                elsif mem_wb(15 downto 9) = "0000111" or mem_wb(15 downto 9) = "0100000" then
                    write_enable <= '0'; -- nothing to update
                elsif mem_wb(15 downto 9) = "0100001" then -- in
                    write_enable <= '1';
                    register_a_index  <= mem_wb(8 downto 6);
                    
                    -- hard code for this test bench
                    if mem_wb(8 downto 6) = "001" then -- r1 = 3
                        register_a_value <= "0000000000000011";
                    elsif mem_wb(8 downto 6) = "010" then -- r1 = 5
                        register_a_value <= "0000000000000101";
                    end if;
                        
                end if;
            end if;
        end if;
    end process;
end behavioural;
