LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_Arith.all;

ENTITY pulse_counter_avalon IS
	PORT(
		clk: in std_logic;
		reset_n : in std_logic;
		address : in std_logic_vector(1 downto 0);
		read : in std_logic;
		write : in std_logic;
		readdata : out std_logic_vector(31 downto 0);
		writedata : in std_logic_vector(31 downto 0);
		i_data    : in std_logic
		);
END pulse_counter_avalon;

architecture sol of pulse_counter_avalon is

component pulse_counter is
	port (
		i_clk :	in  std_logic;
		i_en	:	in std_logic;
		i_data  :	in  std_logic;
		i_reset	:	in  std_logic;
		o_pulse	:	out std_logic_vector(11 downto 0)
	);
end component pulse_counter;

component CLOCK_DIV_50 IS
    PORT
    (  CLOCK_50MHz    :IN   STD_LOGIC;
       CLOCK_1MHz     :OUT  STD_LOGIC;
       CLOCK_100KHz   :OUT  STD_LOGIC;
       CLOCK_10KHz    :OUT  STD_LOGIC;
       CLOCK_1KHz     :OUT  STD_LOGIC;
       CLOCK_100Hz    :OUT  STD_LOGIC;
       CLOCK_10Hz     :OUT  STD_LOGIC;
       CLOCK_1Hz      :OUT  STD_LOGIC);
END component CLOCK_DIV_50;

component ANTIREBOTE IS
	PORT(	PB_N 	: IN	STD_LOGIC;
			CLOCK_100Hz	:	 IN	STD_LOGIC;
			PB_SIN_REBOTE		: OUT	STD_LOGIC);
END component ANTIREBOTE;

	--Address for different registers
		constant REG_INPUT_0_OFST 	: std_logic_vector(1 downto 0) := "00";--Address for enable de to charge the "entry"
		constant REG_INPUT_1_OFST 	: std_logic_vector(1 downto 0) := "01";

		signal reg_input_0 : unsigned(writedata'range); --creating register 1 for Inputs -> Enables de PWM signal creation
		signal reg_input_1 : std_logic_vector(31 downto 0);
		signal w_clk, w_clk_ant, w_data, w_reset : std_logic := '0';
begin

	-- Avalon-MM slave write
		process(clk, reset_n)
		begin
			if reset_n = '0' then
				reg_input_0 <= (others => '0');
				elsif rising_edge(clk) then
					if write = '1' then
						case address is
							when REG_INPUT_0_OFST => 	reg_input_0 <= unsigned(writedata);
							when REG_INPUT_1_OFST =>	null;
							when others => null;
						end case;
					end if;
				end if;
		end process;

	-- Avalon-MM slave read
		process(clk, reset_n)
		begin
			if rising_edge(clk) then
				if read = '1' then
					case address is
						when REG_INPUT_0_OFST =>	readdata <= std_logic_vector(reg_input_0); --assign readdata<=enable
						when REG_INPUT_1_OFST =>	readdata <= std_logic_vector(reg_input_1); --assign readdata<=enable
						when others =>	readdata <= (others => '0');
					end case;
				end if;
			end if;
		end process;
		

		
	w_reset <= not (reset_n);
		
	pulse_counter_1 : pulse_counter
		port map (
					i_clk =>	w_clk,
					i_en	=>	reg_input_0(0),
					i_data  =>	w_data,
					i_reset	=>	w_reset,
					o_pulse	=> reg_input_1(11 downto 0)
					);
					
	clk_div :	CLOCK_DIV_50 
		PORT MAP ( 	 
					CLOCK_50MHz    =>	clk,
					CLOCK_1MHz     =>	open,
					CLOCK_100KHz   =>	open,
					CLOCK_10KHz    =>	w_clk_ant,
					CLOCK_1KHz     =>	w_clk,
					CLOCK_100Hz    =>	open,
					CLOCK_10Hz     =>	open,
					CLOCK_1Hz      =>	open
					);

	anti_reb : ANTIREBOTE 
		PORT MAP (	
					PB_N 	=>	i_data,
					CLOCK_100Hz	=>	w_clk_ant,
					PB_SIN_REBOTE		=> w_data
					);
END sol;