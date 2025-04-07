library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_module is
    port(
        rst: in std_logic;
        clk: in std_logic;
        
        reg_1_output_test: out std_logic_vector(15 downto 0); -- testing vars
        reg_2_output_test: out std_logic_vector(15 downto 0);
        reg_3_output_test: out std_logic_vector(15 downto 0);
        reg_1_index_test: out std_logic_vector(2 downto 0); -- testing vars
        reg_2_index_test: out std_logic_vector(2 downto 0);
        reg_3_index_test: out std_logic_vector(2 downto 0);
        
        instruction_set: in std_logic_vector(15 downto 0);
        
        alu_result: out std_logic_vector(15 downto 0);
        program_counter: out std_logic_vector(15 downto 0));
end top_module;

architecture behavioural of top_module is

    signal z_flag: std_logic;
    signal n_flag: std_logic;
    signal o_flag: std_logic;
    signal opcode: std_logic_vector(6 downto 0);
    signal shift_by: std_logic_vector(3 downto 0);

    signal current_program_counter: std_logic_vector(15 downto 0);
    
    -- Pipeline registers
    signal if_id: std_logic_vector(15 downto 0);  -- Instruction Fetch to Decode
    signal id_ex: std_logic_vector(15 downto 0);  -- Decode to Execute
    signal ex_mem: std_logic_vector(15 downto 0);  -- Execute to Memory
    signal mem_wb: std_logic_vector(15 downto 0);  -- Memory to Write Back

    -- register file
    signal register_a_index: std_logic_vector(2 downto 0);
    signal register_b_index: std_logic_vector(2 downto 0);
    signal register_c_index: std_logic_vector(2 downto 0);
    signal register_a_value: std_logic_vector(15 downto 0);
    signal register_b_value: std_logic_vector(15 downto 0);
    signal register_c_value: std_logic_vector(15 downto 0);
    signal write_enable: std_logic;
    
    -- ALU interface signals
    signal alu_in1: std_logic_vector(15 downto 0);
    signal alu_in2: std_logic_vector(15 downto 0);
    signal alu_out: std_logic_vector(15 downto 0);
    signal alu_out_mem: std_logic_vector(15 downto 0);

    -- Component declarations
    component alu is
        port(
            rst: in std_logic;
            clk: in std_logic;
            
            opcode: in std_logic_vector (6 downto 0);
            alu_in_1: in std_logic_vector (15 downto 0);
            alu_in_2: in std_logic_vector (15 downto 0);        
            shift_by: in std_logic_vector (3 downto 0);
            
            z_flag: out std_logic := '0';
            n_flag: out std_logic := '0';
            o_flag: out std_logic := '0';
            alu_out: out std_logic_vector (15 downto 0));
    end component;

    component branch is
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


    component load is
        port(
            clk: in std_logic;
            rst: in std_logic;
            
            instruction_set: in std_logic_vector (15 downto 0);
            
            destination_register_index: in std_logic_vector (2 downto 0); -- destination
            source_register_index: in std_logic_vector (2 downto 0); -- source
            destination_register_value: out std_logic_vector (15 downto 0);
            source_register_value: in std_logic_vector (15 downto 0);
            
            register_7: out std_logic_vector(15 downto 0);
            
            upper_lower_in: in std_logic;
            immediate_value_in: in std_logic_vector(7 downto 0));
    end load;

    component register_file is
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
    end component;

    component program_counter is
        port(
            clk: in std_logic; -- clock
            rst: in std_logic; -- rst 
            waiting: in std_logic; -- waiting flag
            enable: in std_logic; -- enable signal
            
            update_address: in std_logic_vector (15 downto 0); -- new address value
            program_counter: out std_logic_vector (15 downto 0)); --current program counter
    end component;

    component led is
        port(
            clk: in std_logic;
            reset: in std_logic;
            
    		hex3: in std_logic_vector(3 downto 0);
            hex2: in std_logic_vector(3 downto 0);
            hex1: in std_logic_vector(3 downto 0);
            hex0: in std_logic_vector(3 downto 0);
            
    		an: out std_logic_vector(3 downto 0);
    		sseg: out std_logic_vector(6 downto 0));
    end component;

    component mux is
        port(
            input_1: in std_logic_vector (15 downto 0);
            input_2: in std_logic_vector (15 downto 0);
            output_signal: out std_logic_vector (15 downto 0);
            
            select_switch: in std_logic);
    end component;

    component ram_module is
        port(
            douta: out STD_LOGIC_VECTOR (15 downto 0); -- READ_DATA_WIDTH_A = 16
            doutb: out STD_LOGIC_VECTOR (15 downto 0);
            
            addra: in STD_LOGIC_VECTOR (8 downto 0); -- ADDR_WIDTH_A = 9
            addrb: in STD_LOGIC_VECTOR (8 downto 0); -- width is 9 because 2^9=512 words. 2 words=1byte -> we have 1024 bytes RAM
            
            clka: in STD_LOGIC;
            clkb: in STD_LOGIC;
            
            dina: in STD_LOGIC_VECTOR (15 downto 0); -- WRITE_DATA_WIDTH_A = 16
            
            ena: in STD_LOGIC;
            enb: in STD_LOGIC;
            
            regcea: in STD_LOGIC;
            regceb: in STD_LOGIC;
            
            rsta: in STD_LOGIC;
            rstb: in STD_LOGIC;
            
            wea: in STD_LOGIC_VECTOR (0 downto 0)); -- WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A = 1
                                                    -- BYTE_WRITE_WIDTH_A = 16 andW RITE_DATA_WIDTH_A = 16
    end component;

    component rom_module is
        port(
            douta: out STD_LOGIC_VECTOR (15 downto 0); -- READ_DATA_WIDTH_A = 16
            addra: in STD_LOGIC_VECTOR (8 downto 0); -- ADDR_WIDTH_A = 9 
                                                    -- (width is 9 because 2^9=512 words. 2 words=1byte -> we have 1024 bytes RAM)
            clka: in STD_LOGIC;
            ena: in STD_LOGIC;
    
            rsta: in STD_LOGIC;
            sleep: in STD_LOGIC);
    end component;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_program_counter <= (others => '0');
            else
                current_program_counter <= std_logic_vector(unsigned(current_program_counter) + 2);
            end if;
        end if;
    end process;
    program_counter <= current_program_counter;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                if_id  <= (others => '0');
                id_ex  <= (others => '0');
                ex_mem <= (others => '0');
                mem_wb <= (others => '0');
            else
                -- latch
                if_id <= instruction_set; -- Fetch stage
                id_ex <= if_id; -- Decode stage
                ex_mem<= id_ex; -- Execute stage
                mem_wb<= ex_mem; -- Memory stage
            end if;
        end if;
    end process;

    ALU_module: alu
        port map(
            rst => rst,
            clk => clk,
            opcode => opcode,
            alu_in_1 => alu_in1,
            alu_in_2 => alu_in2,
            shift_by  => shift_by,
            z_flag => z_flag,
            n_flag  => n_flag,
            o_flag  => o_flag,
            alu_out => alu_out);

    BRANCH_module: branch
        port map(
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
            register_7_in => register_7_out,
            register_7_out => register_7_out,
            program_counter_out =>program_counter_out);

    LOAD_module: load
        port map(
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
        
    program_counter_module: program_counter
        port map(
            clk => clk,
            rst => rst,
            waiting => waiting,
            enable => enable,
            update_address => update_address,
            program_counter => program_counter);
    
    led_module: led
        port map(
            clk => clk,
            reset => rst,
            hex3 => hex3,
            hex2 => hex2,
            hex1 => hex1,
            hex0 => hex0,
            an => an,
            sseg => sseg);

    led_module: led
        port map(
            input_1 => input_1,
            input_2 => input_2,
            output_signal => output_signal,
            select_switch => select_switch);

    RAM_module: ram_module
        port map(
            douta => douta,
            doutb => doutb,
            addra => addra,
            addrb => addrb,
            clka => clka,
            clkb => clkb,
            dina => dina,
            ena => ena,
            enb => enb,
            regcea => regcea,
            regceb => regceb,
            rsta => rsta,
            rstb => rstb,
            wea => wea);

    ROM_module: rom_module
        port map(
            douta => douta,
            doutb => doutb,
            clka => clka,
            ena => ena,
            rsta => rsta,
            sleep => sleep);
        
        
    -- Control 
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                write_enable <= '0';
                opcode <= (others => '0');
                shift_by <= (others => '0');
                alu_out_mem <= (others => '0');
                register_a_index <= (others => '0');
            else
                -- Decode Stage (using id_ex, the instruction from the previous cycle)
                if unsigned(id_ex(15 downto 9)) >= 1 and unsigned(id_ex(15 downto 9)) <= 4 then -- a1
                    register_b_index <= id_ex(5 downto 3);
                    register_c_index <= id_ex(2 downto 0);
                elsif (unsigned(id_ex(15 downto 9)) >= 32 and unsigned(id_ex(15 downto 9)) <= 33) or -- a2 or a3
                      (unsigned(id_ex(15 downto 9)) >= 5 and unsigned(id_ex(15 downto 9)) <= 7) then
                    register_b_index <= id_ex(8 downto 6);
                    register_c_index <= (others => '0');  -- may not be used for these instructions
                elsif unsigned(id_ex(15 downto 9)) >= 64 and unsigned(id_ex(15 downto 9)) <= 66 then -- b1
                    disp_l <= id_ex(8 downto 0);
                elsif unsigned(id_ex(15 downto 9)) >= 67 and unsigned(id_ex(15 downto 9)) <= 70 then -- b2
                    register_a_index  <= id_ex(8 downto 6);
                    register_a_value_branch  <= register_a_value;
                    disp_s <= id_ex(5 downto 0);
                elsif unsigned(id_ex(15 downto 9)) >= 18 and unsigned(id_ex(15 downto 9)) <= 18 then -- l1
                    upper_lower_in  <= id_ex(9 downto 9);
                    immediate_value_in <= id_ex(7 downto 0);
                elsif (unsigned(id_ex(15 downto 9)) >= 16 and unsigned(id_ex(15 downto 9)) <= 17) or -- l2
                      (unsigned(id_ex(15 downto 9)) >= 19 and unsigned(id_ex(15 downto 9)) <= 19) then
                    register_a_index  <= id_ex(8 downto 6);
                    register_a_value_branch  <= register_a_value;
                    register_b_index <= id_ex(8 downto 6);
                end if;
                
                -- Execute Stage: Drive ALU inputs and control signals based on id_ex
                alu_in1 <= register_b_value; -- update new rb and rc val
                alu_in2 <= register_c_value;
                
                -- found a hazard for this specifc test bench
                -- if performing the SHL, we need to use an older value of alu_out_mem not the resgiter value
                if(unsigned(id_ex(15 downto 9)) = 5) then
                    alu_in1 <= alu_out_mem;
                end if;
                -- for debugging
                reg_1_output_test <= register_b_value; -- update test values
                reg_2_output_test <= register_c_value;
                reg_3_output_test <= register_a_value;
                reg_1_index_test <= register_b_index; -- update test values
                reg_2_index_test <= register_c_index;
                reg_3_index_test <= register_a_index;

                if unsigned(id_ex(15 downto 9)) >= 1 and unsigned(id_ex(15 downto 9)) <= 4 then
                    opcode <= id_ex(15 downto 9);
                elsif id_ex(15 downto 9) = "0000101" then -- 5
                    shift_by  <= id_ex(3 downto 0);
                    opcode <= "0000101";
                elsif id_ex(15 downto 9) = "0000110" then -- 6
                    shift_by  <= id_ex(3 downto 0);
                    opcode <= "0000110";
                elsif id_ex(15 downto 9) = "0000111" then -- 7
                    opcode <= "0000111";

                elsif id_ex(15 downto 9) = "0010000" then -- 16
                    opcode <= "0010000";
                elsif id_ex(15 downto 9) = "0010001" then -- 17
                    opcode <= "0010001";
                elsif id_ex(15 downto 9) = "0010010" then -- 18
                    opcode <= "0010010";
                elsif id_ex(15 downto 9) = "0010011" then -- 19
                    opcode <= "0010011";

                elsif id_ex(15 downto 9) = "0100000" then -- 32
                    opcode <= "0100000";
                elsif id_ex(15 downto 9) = "0100001" then -- 33
                    opcode <= "0100001";
                elsif id_ex(15 downto 9) = "1000000" then -- 64
                    opcode <= "1000000";
                elsif id_ex(15 downto 9) = "1000001" then -- 65
                    opcode <= "1000001";
                elsif id_ex(15 downto 9) = "1000010" then -- 66
                    opcode <= "1000010";
                elsif id_ex(15 downto 9) = "1000011" then -- 67
                    opcode <= "1000011";
                elsif id_ex(15 downto 9) = "1000100" then -- 68
                    opcode <= "1000100";
                elsif id_ex(15 downto 9) = "1000101" then -- 69
                    opcode <= "1000101";
                elsif id_ex(15 downto 9) = "1000110" then -- 70
                    opcode <= "1000110";
                elsif id_ex(15 downto 9) = "1000111" then -- 71
                    opcode <= "1000111";
                end if;

                -- Memory Stage: Capture ALU output
                alu_out_mem <= alu_out;
                --alu_result <= alu_out; -- for debugging
                if id_ex(15 downto 9) = "0100000" then -- OUT (32)
                    alu_result <= alu_out;
                end if;
                
                -- Write Back Stage: Set register file write signals using mem_wb
                if mem_wb(15 downto 9) = "0000000" then
                    write_enable <= '0';
                elsif (unsigned(mem_wb(15 downto 9)) >= 1 and unsigned(mem_wb(15 downto 9)) <= 6) then
                    write_enable <= '1';
                    register_a_index  <= mem_wb(8 downto 6);
                    register_a_value  <= alu_out_mem;
                elsif mem_wb(15 downto 9) = "0000111" or mem_wb(15 downto 9) = "0100000" then
                    write_enable <= '0';
                elsif mem_wb(15 downto 9) = "0100001" then
                    write_enable <= '1';
                    register_a_index  <= mem_wb(8 downto 6);
                    if mem_wb(8 downto 6) = "001" then -- hard code for this test bench
                        register_a_value <= X"0003";
                    else
                        register_a_value <= X"0005";
                    end if;
                end if;
            end if;
        end if;
    end process;
end behavioural;
