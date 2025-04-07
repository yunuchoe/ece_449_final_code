library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- XPM_MEMORY_DPDISTRAM
Library xpm;
use xpm.vcomponents.all;

entity DPDISTRAM is
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
    end DPDISTRAM;

architecture behavioral of DPDISTRAM is -- make DPDISTRAM
begin
    xpm_memory_dpdistram_inst : xpm_memory_dpdistram
    generic map (
        ADDR_WIDTH_A => 9, -- DECIMAL
        ADDR_WIDTH_B => 9, -- DECIMAL
        BYTE_WRITE_WIDTH_A => 16, -- DECIMAL
        CLOCKING_MODE => "common_clock", -- String
        MEMORY_INIT_FILE => "none", -- String
        MEMORY_INIT_PARAM => "0", -- String
        MEMORY_OPTIMIZATION => "true", -- String
        MEMORY_SIZE => 8192, -- DECIMAL
        MESSAGE_CONTROL => 0, -- DECIMAL
        READ_DATA_WIDTH_A => 16, -- DECIMAL
        READ_DATA_WIDTH_B => 16, -- DECIMAL
        READ_LATENCY_A => 1, -- DECIMAL (change latency 2 -> 1)
        READ_LATENCY_B => 1, -- DECIMAL
        READ_RESET_VALUE_A => "0", -- String
        READ_RESET_VALUE_B => "0", -- String
        RST_MODE_A => "SYNC", -- String
        RST_MODE_B => "SYNC", -- String
        USE_EMBEDDED_CONSTRAINT => 0, -- DECIMAL
        USE_MEM_INIT => 1, -- DECIMAL
        WRITE_DATA_WIDTH_A => 16 -- DECIMAL
    )
      
    port map (
        douta => douta, -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
        doutb => doutb, -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
        addra => addra, -- ADDR_WIDTH_A-bit input: Address for port A write and read operations.
        addrb => addrb, -- ADDR_WIDTH_B-bit input: Address for port B write and read operations.
        clka => clka, -- 1-bit input: Clock signal for port A. Also clocks port B when parameter
        -- CLOCKING_MODE is "common_clock".
        clkb => clkb, -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
        -- "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
        dina => dina, -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
        ena => ena, -- 1-bit input: Memory enable signal for port A. Must be high on clock cycles when read
        -- or write operations are initiated. Pipelined internally.
        enb => enb, -- 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read
        -- or write operations are initiated. Pipelined internally.
        regcea => regcea, -- 1-bit input: Clock Enable for the last register stage on the output data path.
        regceb => regceb, -- 1-bit input: Do not change from the provided value.
        rsta => rsta, -- 1-bit input: Reset signal for the final port A output register stage. Synchronously
        -- resets output port douta to the value specified by parameter READ_RESET_VALUE_A.
        rstb => rstb, -- 1-bit input: Reset signal for the final port B output register stage. Synchronously
        -- resets output port doutb to the value specified by parameter READ_RESET_VALUE_B.
        wea => wea -- WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1
        -- bit wide when word-wide writes are used. In byte-wide write configurations, each bit
        -- controls the writing one byte of dina to address addra. For example, to
        -- synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea
        -- would be 4'b0010.
    );
    -- End of xpm_memory_dpdistram_inst instantiation

 end behavioral;
