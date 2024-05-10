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
--|
--| ALU OPCODES:
--|
--|     ADD     000
--|
--|
--|
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity ALU is
        port(
            i_state : in std_logic_vector(3 downto 0);
            i_op : in std_logic_vector(2 downto 0);
            i_B : in std_logic_vector(7 downto 0);
            i_A : in std_logic_vector(7 downto 0);
            o_C : out std_logic;
            o_zero : out std_logic;
            o_sign : out std_logic;
            o_result : out std_logic_vector(7 downto 0)
        );
end ALU;

architecture behavioral of ALU is 
  
	-- declare components and signals
	signal w_B : std_logic_vector(7 downto 0);
	signal w_or : std_logic_vector(7 downto 0);
	signal w_and : std_logic_vector(7 downto 0);
	signal w_andOr : std_logic_vector(7 downto 0);
	signal w_leftShift : std_logic_vector(7 downto 0);
    signal w_rightShift : std_logic_vector(7 downto 0);
    signal w_addSub : std_logic_vector(7 downto 0);
    signal w_overflow : std_logic_vector(8 downto 0);
    signal w_result : std_logic_vector(7 downto 0);
        
    constant k_one : std_logic_vector(7 downto 0) := x"01";
  
begin
	-- PORT MAPS ----------------------------------------
    w_B <= i_B when i_op(0) = '0' else std_logic_vector(unsigned(not i_B) + unsigned(k_one));
           
    w_or <= i_B or i_A;
    w_and <= i_B and i_A;
    
    w_andOr <= w_or when i_op(0) = '0' else w_and;
    
    
    w_leftShift <= std_logic_vector(shift_left(unsigned(i_A),to_integer(unsigned(i_B(2 downto 0)))));
    w_rightShift <= std_logic_vector(shift_right(unsigned(i_A),to_integer(unsigned(i_B(2 downto 0)))));
     
    
    w_addSub <= std_logic_vector(unsigned(w_B) + unsigned(i_A));
    w_overflow <= std_logic_vector(unsigned('0' & w_B) + unsigned('0' & i_A));
    
    
    w_result <= w_addSub when i_op(2 downto 1) = "00" else
                w_andOr when i_op(2 downto 1) = "01" else
                w_leftShift when i_op(2 downto 1) = "10" else
                w_rightShift;
                
    o_C <= w_overflow(8) when i_state = "0100" and (i_op = "000" or i_op = "001") else '0';
                
    o_zero <= '1' when w_result = x"00" and i_state = "0100" else '0';
    
    o_sign <= w_result(7) when i_state = "0100";
    
    o_result <= w_result;	
	
	
end behavioral;
