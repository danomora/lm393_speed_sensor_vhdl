library ieee;
use ieee.std_logic_1164.all;
 
entity pulse_counter is
	port (
		i_clk :	in  std_logic;
		i_en	:	in std_logic;
		i_data  :	in  std_logic;
		i_reset	:	in  std_logic;
		o_pulse	:	out std_logic_vector(11 downto 0)
	);
end entity pulse_counter;
 
architecture sol of pulse_counter is

component up_counter is
    port (
        cout   :out std_logic_vector (11 downto 0);  
        enable :in  std_logic;                      
        clk    :in  std_logic;                    
        reset  :in  std_logic                      
    );
end component up_counter;



type estate is (ta, tb);
signal w_pulse, t_cout, p_cout : std_logic_vector(11 downto 0) := "000000000000";
signal p_enable, p_reset, t_enable, t_reset : std_logic := '0';
signal state : estate := ta;
begin
	
	process (t_cout)
		begin
			if t_cout = "001111101000" then
				w_pulse <= p_cout;
				state <= tb;
			else
				w_pulse <= w_pulse;
				state <= ta;
			end if;
	end process;
	
	process (i_clk)
		begin
			if rising_edge(i_clk) then
				case state is
					when ta =>
						p_reset	<= '0';
						t_reset	<= '0';
					when tb =>
						p_reset	<= '1';
						t_reset	<= '1';
				end case;
			end if;
	end process;
o_pulse <= w_pulse;
p_enable <= '1';
t_enable <= '1';
	
p_counter : up_counter PORT MAP(
											cout	=>	p_cout,
											enable => p_enable,                      
											clk	=> i_data,                    
											reset	=> p_reset     									
											);
											
t_counter : up_counter PORT MAP(
											cout	=>	t_cout,
											enable => t_enable,                      
											clk	=> i_clk,                    
											reset	=> t_reset      									
											);

											
end architecture sol;