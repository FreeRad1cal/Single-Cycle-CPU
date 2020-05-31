library IEEE;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity multiplier is
	generic (n: natural := 32);
	port (a, b:		in std_logic_vector(n-1 downto 0);
			product:	out std_logic_vector(2*n-1 downto 0));
end multiplier;

architecture struct_multiplier of multiplier is
	type temp_t is array (n-1 downto 0) of std_logic_vector(n-1 downto 0);
	type adder_in_out_t is array (n-2 downto 0) of std_logic_vector(n-1 downto 0);
	signal temp: temp_t;
	signal adder_a, adder_b, adder_out: adder_in_out_t;
	signal adder_c: std_logic_vector(n-2 downto 0);
begin
	
	g1: for i in 0 to n-1 generate
		g2: for j in 0 to n-1 generate
			temp(j)(i) <= a(j) and b(i);
		end generate;
	end generate;
	
	adder_a(0) <= '0' & temp(0)(n-1 downto 1);
	adder_b(0) <= temp(1);
	product(0) <= temp(0)(0);
	
	g3: for i in 1 to n-2 generate
		adder_a(i) <= adder_c(i-1) & adder_out(i-1)(n-1 downto 1);
		adder_b(i) <= temp(i+1);
	end generate;
	
	g4: for i in 0 to n-3 generate
		product(i+1) <= adder_out(i)(0);
	end generate;
	
	g5: for i in 0 to n-2 generate
		c: entity work.carry_lookahead_adder
			generic map(n => n)
			port map(c_in => '0', a => adder_a(i), b => adder_b(i), sum => adder_out(i), c_out => adder_c(i));
	end generate;
	
	product(2*n-1 downto n-1) <= adder_c(n-2) & adder_out(n-2);

end struct_multiplier;