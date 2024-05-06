--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_basys3 is
    port(
        -- inputs
        clk   : in std_logic;    -- native 100MHz FPGA clock
        sw    : in std_logic_vector(7 downto 0);
        btnU  : in std_logic;    -- master_reset
        btnC  : in std_logic;    -- advance
        
        -- outputs
        led   : out std_logic_vector(15 downto 0);
        seg   : out std_logic_vector(6 downto 0);
        an    : out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
    signal w_cycle  : std_logic_vector(3 downto 0);
    signal w_op1    : std_logic_vector(7 downto 0);
    signal w_op2    : std_logic_vector(7 downto 0);
    signal w_result : std_logic_vector(7 downto 0);
    signal w_out    : std_logic_vector(7 downto 0);
    signal w_sign   : std_logic_vector(3 downto 0);
    signal w_hund   : std_logic_vector(3 downto 0);
    signal w_tens   : std_logic_vector(3 downto 0);
    signal w_ones   : std_logic_vector(3 downto 0);
    signal w_data   : std_logic_vector(3 downto 0);
    signal w_clk    : std_logic;
    signal w_sel    : std_logic_vector(3 downto 0);
    signal w_seg    : std_logic_vector(6 downto 0);
    signal w_zero   : std_logic;
	
    component sevenSegDecoder is
        Port ( 
            i_D : in STD_LOGIC_VECTOR (3 downto 0);
            o_S : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component sevenSegDecoder;
    
    component clock_divider is
        generic ( constant k_DIV : natural := 2);
        port (  
            i_clk    : in  std_logic;     -- basys3 clk
            i_reset  : in  std_logic;     -- asynchronous
            o_clk    : out std_logic      -- divided (slow) clock
        );
    end component clock_divider;
    
    component ALU is
        port(
            i_state   : in std_logic_vector(3 downto 0);
            i_op      : in std_logic_vector(2 downto 0);
            i_B       : in std_logic_vector(7 downto 0);
            i_A       : in std_logic_vector(7 downto 0);
            o_C       : out std_logic;
            o_zero    : out std_logic;
            o_sign    : out std_logic;
            o_result  : out std_logic_vector(7 downto 0)
        );
    end component ALU;
     
    component Controller_fsm is
        Port ( 
            i_reset : in STD_LOGIC;
            i_adv   : in STD_LOGIC;
            i_clk : in STD_LOGIC;
            o_cycle : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component Controller_fsm;
     
    component twoscomp_decimal is
        port (
            i_binary   : in  std_logic_vector(7 downto 0);
            o_negative : out std_logic;
            o_hundreds : out std_logic_vector(3 downto 0);
            o_tens     : out std_logic_vector(3 downto 0);
            o_ones     : out std_logic_vector(3 downto 0)
        );
    end component twoscomp_decimal;
     
    component TDM4 is
        generic ( constant k_WIDTH : natural := 4); -- bits in input and output
        Port ( 
            i_clk   : in  STD_LOGIC;
            i_reset : in  STD_LOGIC;  -- asynchronous
            i_D3    : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            i_D2    : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            i_D1    : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            i_D0    : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            o_data  : out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
            o_sel   : out STD_LOGIC_VECTOR (3 downto 0)  -- selected data line (one-cold)
        );
    end component TDM4;

begin
    -- Clock Divider
    clock_divider_inst : clock_divider
        generic map ( k_DIV => 250000 ) -- 200 Hz clock from 100 MHz
        port map (
            i_clk   => clk,
            i_reset => btnU,
            o_clk   => w_clk
        );
	
    -- Controller FSM
    Controller_fsm_inst : Controller_fsm
        port map (
            i_reset => btnU,
            i_adv   => btnC,
            i_clk => clk,
            o_cycle => w_cycle
        );
            
    -- LED assignment for debugging
    led(3 downto 0) <= w_cycle;
	
    -- ALU instantiation
    ALU_inst : ALU
        port map (
            i_state  => w_cycle,
            i_A      => w_op1,
            i_B      => w_op2,
            i_op     => sw(2 downto 0),
            o_result => w_result,
            o_C      => led(13),
            o_zero   => w_zero,
            o_sign   => led(15)
        );
	
    -- LED for zero signal
    led(14) <= w_zero;
	
    w_out <= sw when w_cycle = x"1" or w_cycle = x"2" else
             w_result when w_cycle = x"4" else
             x"00";
	
    -- Two's complement decoder instantiation
    twosComp_decimal_inst : twoscomp_decimal
        port map (
            i_binary   => w_out,
            o_negative => w_sign(0),
            o_hundreds => w_hund,
            o_tens     => w_tens,
            o_ones     => w_ones
        );
	
    -- TDM4 instantiation
    TDM4_inst : TDM4 
        port map (
            i_D3    => w_sign,
            i_D2    => w_hund,
            i_D1    => w_tens,
            i_D0    => w_ones,
            i_clk   => w_clk,
            i_reset => btnU,
            o_data  => w_data,
            o_sel   => w_sel
        );
	    an <= w_sel;   
	       
    -- Seven-segment decoder instantiation
    sevenSegDecoder_inst : sevenSegDecoder
        port map (
            i_D => w_data,
            o_S => w_seg
        );
        
        Seg <= "0111111" when w_sign(0) = '1' and w_sel(3) = '0' else 
                "1111111" when w_cycle = x"8" else w_seg;
        
    
	
    -- LED initialization
    led(12 downto 4) <= (others => '0');
	
    -- Process for operand assignment based on cycle
    process(w_cycle)
    begin
        if rising_edge(w_cycle(1)) then
            w_op1 <= sw(7 downto 0);
        end if;
        if rising_edge(w_cycle(2)) then
            w_op2 <= sw(7 downto 0);
        end if;
    end process;
    
end top_basys3_arch;

