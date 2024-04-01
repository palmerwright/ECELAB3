--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
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
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
	  port(
		  i_clk, i_reset  : in    std_logic;
          i_left, i_right : in    std_logic;
          o_lights_L      : out   std_logic_vector(2 downto 0);
          o_lights_R      : out   std_logic_vector(2 downto 0)
    );
	end component thunderbird_fsm;

	-- test I/O signals
	
	signal tb_i_clk   : std_logic := '0';
    signal tb_i_reset : std_logic := '0';
    signal tb_i_left  : std_logic := '0';
    signal tb_i_right : std_logic := '0';
    signal tb_o_lights_L : std_logic_vector(2 downto 0);
    signal tb_o_lights_R : std_logic_vector(2 downto 0);
	
	-- constants
	
	
begin
	-- Instantiate the Unit Under Test (UUT)
uut: thunderbird_fsm
port map (
    i_clk    => tb_i_clk,
    i_reset  => tb_i_reset,
    i_left   => tb_i_left,
    i_right  => tb_i_right,
    o_lights_L => tb_o_lights_L,
    o_lights_R => tb_o_lights_R
);

-- Clock process
clock_process : process
begin
    while true loop
        tb_i_clk <= '0';
        wait for 10 ns;  -- Adjust the timing to suit your needs
        tb_i_clk <= '1';
        wait for 10 ns;
    end loop;
end process;

-- Test Plan Process
test_process : process
begin
    -- Apply reset
    tb_i_reset <= '1';
    wait for 20 ns;
    tb_i_reset <= '0';
    
    -- Test sequence 1: Left turn signal
    tb_i_left <= '1';
    wait for 100 ns;
    tb_i_left <= '0';
    wait for 100 ns;  -- Wait to observe the FSM returning to the OFF state

    -- Test sequence 2: Right turn signal
    tb_i_right <= '1';
    wait for 100 ns;
    tb_i_right <= '0';
    wait for 100 ns;

    -- Test sequence 3: Simultaneous Left and Right signals (hazard lights scenario)
    tb_i_left <= '1';
    tb_i_right <= '1';
    wait for 100 ns;
    tb_i_left <= '0';
    tb_i_right <= '0';
    wait for 100 ns;

    -- Test sequence 4: Quick Left then Right - testing state transition robustness
    tb_i_left <= '1';
    wait for 50 ns;  -- Shorter duration to simulate quick switch
    tb_i_left <= '0';
    wait for 10 ns;  -- Minimal delay before switching to right
    tb_i_right <= '1';
    wait for 50 ns;
    tb_i_right <= '0';
    wait for 100 ns;

    -- Test sequence 5: Reset functionality while signals are active
    tb_i_left <= '1';
    wait for 50 ns;
    tb_i_reset <= '1';  -- Assert reset while left signal is active
    wait for 20 ns;
    tb_i_reset <= '0';
    wait for 50 ns;  -- Wait to observe behavior after reset
    tb_i_left <= '0';

    -- Add more test sequences as needed to cover all edge cases and scenarios

    -- Complete the simulation
    wait;
end process;
end test_bench;
