library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- XPM_MEMORY_SPROM
library xpm;
use xpm.vcomponents.all;

entity SPROM is
    port(
        douta: out STD_LOGIC_VECTOR (15 downto 0); -- READ_DATA_WIDTH_A = 16
        addra: in STD_LOGIC_VECTOR (8 downto 0); -- ADDR_WIDTH_A = 9 
                                                -- (width is 9 because 2^9=512 words. 2 words=1byte -> we have 1024 bytes RAM)
        clka: in STD_LOGIC;
        ena: in STD_LOGIC;

        rsta: in STD_LOGIC;
        sleep: in STD_LOGIC);
end SPROM;

architecture behavioral of SPROM is -- make SPROM
begin
    xpm_memory_sprom_inst : xpm_memory_sprom
    generic map (
        ADDR_WIDTH_A => 9, -- DECIMAL
        AUTO_SLEEP_TIME => 0, -- DECIMAL
        ECC_MODE => "no_ecc", -- String
        MEMORY_INIT_FILE => "testb1.mem", -- String !! might need .mem file later
        MEMORY_INIT_PARAM => "0", -- String
        MEMORY_OPTIMIZATION => "true", -- String
        MEMORY_PRIMITIVE => "auto", -- String
        MEMORY_SIZE => 8192, -- DECIMAL
        MESSAGE_CONTROL => 0, -- DECIMAL
        READ_DATA_WIDTH_A => 16, -- DECIMAL
        READ_LATENCY_A => 1, -- DECIMAL
        READ_RESET_VALUE_A => "0", -- String
        --RST_MODE_A => "SYNC", -- String
        USE_MEM_INIT => 1, -- DECIMAL
        WAKEUP_TIME => "disable_sleep" -- String
    )
    port map (
        dbiterra => open, -- 1-bit output: Leave open.
        douta => douta, -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
        sbiterra => open, -- 1-bit output: Leave open.
        addra => addra, -- ADDR_WIDTH_A-bit input: Address for port A read operations.
        clka => clka, -- 1-bit input: Clock signal for port A.
        ena => ena, -- 1-bit input: Memory enable signal for port A. Must be high on clock
        -- cycles when read operations are initiated. Pipelined internally.
        injectdbiterra => '0', -- 1-bit input: Do not change from the provided value.
        injectsbiterra => '0', -- 1-bit input: Do not change from the provided value.
        regcea => '1', -- 1-bit input: Do not change from the provided value.
        rsta => '0', -- 1-bit input: Reset signal for the final port A output register
        -- stage. Synchronously resets output port douta to the value specified
        -- by parameter READ_RESET_VALUE_A.
        sleep => sleep -- 1-bit input: sleep signal to enable the dynamic power saving feature.
    );
    -- End of xpm_memory_sprom_inst instantiation
end behavioral;
