----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2024 03:17:04 PM
-- Design Name: 
-- Module Name: ALU_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU_tb is
end ALU_tb;

architecture Test_Bench of ALU_tb is

component ALU is
        port(
            i_state : in std_logic_vector(3 downto 0);
            i_op : in std_logic_vector(2 downto 0);
            i_B, i_A : in std_logic_vector(7 downto 0);
            o_sign, o_zero, o_C : out std_logic;
            o_result : out std_logic_vector(7 downto 0)
        );
end component ALU;

    -- test I/O signals
	--Inputs
	signal w_clk, w_reset : std_logic := '0';
	signal w_B, w_A : std_logic_vector(7 downto 0) := x"00";
	signal w_op : std_logic_vector(2 downto 0) := o"0";
	signal w_state : std_logic_vector(3 downto 0) := x"4";
	
	--Outputs
    signal w_zero, w_sign, w_C : std_logic;
    signal w_result : std_logic_vector(7 downto 0);
	
	-- constants
	constant k_clk_period : time := 5 ns;

begin
    -- PORT MAPS ----------------------------------------
    ALU_inst : ALU
        port map(
            i_state => w_state,
            i_op => w_op,
            i_B => w_B,
            i_A => w_A,
            o_C => w_C,
            o_zero => w_zero,
            o_sign => w_sign,
            o_result => w_result
            );
    
    -- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    
    clk_proc : process
    begin
        w_clk <= '0';
        wait for k_clk_period/2;
        w_clk <= '1';
        wait for k_clk_period/2;
    end process;
    
    
    -- Test Plan Process --------------------------------
        
        sim_proc: process
        begin
            
            -- test 0 & 0 on all operators
            wait for k_clk_period;
                assert w_result = x"00" report "Incorrect addition" severity failure;
            w_op <= o"1"; wait for k_clk_period;
                assert w_result = x"00" report "Incorrect subtraction" severity failure;
            w_op <= o"2"; wait for k_clk_period;
                assert w_result = x"00" report "Incorrect 'or'" severity failure;
            w_op <= o"3"; wait for k_clk_period;
                assert w_result = x"00" report "Incorrect 'and'" severity failure;
            w_op <= o"4"; wait for k_clk_period;
                assert w_result = x"00" report "Incorrect left shift" severity failure;
            w_op <= o"6"; wait for k_clk_period;
                assert w_result = x"00" report "Incorrect right shift" severity failure;
            -- test flags on an output of 0
                assert w_zero = '1' report "Incorrect zero flag" severity failure;
                assert w_C = '0' report "Incorrect carry flag" severity failure;
                assert w_sign = '0' report "Incorrect sign flag" severity failure;
            -- test flags turn off when not in the third stage
            w_state <= x"1"; wait for k_clk_period;
                assert w_zero = '0' report "Zero flag doesn't shut off" severity failure;
                
                
            -- test 87(01010111) & 18(00010010) on all operators
            w_state <= x"4"; w_A <= x"57"; w_B <= x"12"; w_op <= o"0"; wait for k_clk_period;
                assert w_result = x"69" report "Incorrect addition" severity failure;
            w_op <= o"1"; wait for k_clk_period;
                assert w_result = x"45" report "Incorrect subtraction" severity failure;
                assert w_C = '1' report "Incorrect carry flag" severity failure;
            w_op <= o"2"; wait for k_clk_period;
                assert w_result = x"57" report "Incorrect 'or'" severity failure;
            w_op <= o"3"; wait for k_clk_period;
                assert w_result = x"12" report "Incorrect 'and'" severity failure;
            w_op <= o"4"; wait for k_clk_period;
                assert w_result = "01011100" report "Incorrect left shift" severity failure;
            w_op <= o"6"; wait for k_clk_period;
                assert w_result = "00010101" report "Incorrect right shift" severity failure;
            -- test flags on an output of x15 or 21
                assert w_zero = '0' report "Incorrect zero flag" severity failure;
                assert w_C = '0' report "Incorrect carry flag" severity failure;
                assert w_sign = '0' report "Incorrect sign flag" severity failure;
                
            -- test 2 & 17 on all operators 
            w_A <= x"02"; w_B <= x"11"; w_op <= o"0"; wait for k_clk_period;
                assert w_result = x"13" report "Incorrect addition" severity failure;
            w_op <= o"1"; wait for k_clk_period;
                assert w_result = x"F1" report "Incorrect subtraction" severity failure;
                assert w_sign = '1' report "Incorrect sign flag" severity failure;
                assert w_C = '0' report "Incorrect carry flag" severity failure;
                assert w_zero = '0' report "Incorrect zero flag" severity failure;
            w_op <= o"2"; wait for k_clk_period;
                assert w_result = x"13" report "Incorrect 'or'" severity failure;
            w_op <= o"3"; wait for k_clk_period;
                assert w_result = x"00" report "Incorrect 'and'" severity failure;
            w_op <= o"4"; wait for k_clk_period;
                assert w_result = x"04" report "Incorrect left shift" severity failure;
            w_op <= o"6"; wait for k_clk_period;
                assert w_result = x"01" report "Incorrect right shift" severity failure;
            -- test flags on an output of 1
                assert w_zero = '0' report "Incorrect zero flag" severity failure;
                assert w_C = '0' report "Incorrect carry flag" severity failure;
                assert w_sign = '0' report "Incorrect sign flag" severity failure;
            
            -- test -125 & 11 on all operators
            w_A <= "10000011"; w_B <= "00001011"; w_op <= o"0"; wait for k_clk_period;
                assert w_result = "10001110" report "Incorrect addition" severity failure;
                assert w_sign = '1' report "Incorrect sign flag" severity failure;
            w_op <= o"1"; wait for k_clk_period;
                assert w_C = '1' report "Incorrect carry flag" severity failure;
            w_op <= o"2"; wait for k_clk_period;
                assert w_result = "10001011" report "Incorrect 'or'" severity failure;
            w_op <= o"3"; wait for k_clk_period;
                assert w_result = "00000011" report "Incorrect 'and'" severity failure;
            w_op <= o"4"; wait for k_clk_period;
                assert w_result = "00011000" report "Incorrect left shift" severity failure;
            w_op <= o"6"; wait for k_clk_period;
                assert w_result = "00010000" report "Incorrect right shift" severity failure;
            -- test flags on 16
                assert w_zero = '0' report "Incorrect zero flag" severity failure;
                assert w_C = '0' report "Incorrect carry flag" severity failure;
                assert w_sign = '0' report "Incorrect sign flag" severity failure;
            
            -- test -2 & -2 on all operators
            w_A <= x"FE"; w_B <= x"FE"; w_op <= o"0"; wait for k_clk_period;
                assert w_result = x"FC" report "Incorrect addition" severity failure;
                assert w_sign = '1' report "Incorrect sign flag" severity failure;
                assert w_C = '1' report "Incorrect carry flag" severity failure;
            w_op <= o"1"; wait for k_clk_period;
                assert w_result = x"00" report "Incorrect subtraction" severity failure;
                assert w_zero = '1' report "Incorrect zero flag" severity failure;
                assert w_C = '1' report "Incorrect carry flag" severity failure;
                -- test flags turn off in different state
            w_state <= x"1"; wait for k_clk_period;
                assert w_zero = '0' report "Zero flag incorrectly displayed" severity failure;
                assert w_C = '0' report "Carry flag incorrectly displayed" severity failure;
            w_state <= x"4"; w_op <= o"2"; wait for k_clk_period;
                assert w_result = x"FE" report "Incorrect 'or'" severity failure;
            w_op <= o"3"; wait for k_clk_period;
                assert w_result = x"FE" report "Incorrect 'and'" severity failure;
            w_op <= o"4"; wait for k_clk_period;
                assert w_result = "10000000" report "Incorrect left shift" severity failure;
            w_op <= o"6"; wait for k_clk_period;
                assert w_result = "00000011" report "Incorrect right shift" severity failure;
            -- test flags on 3
                assert w_zero = '0' report "Incorrect zero flag" severity failure;
                assert w_C = '0' report "Incorrect carry flag" severity failure;
                assert w_sign = '0' report "Incorrect sign flag" severity failure;

            wait;
        end process;

end Test_Bench;
