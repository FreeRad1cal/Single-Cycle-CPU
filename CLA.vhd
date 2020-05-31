library IEEE;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

-- carry lookahead adder
entity carry_lookahead_adder is
	generic (n: natural := 32);
	port (c_in: 	in std_logic;
			a:			in std_logic_vector(n-1 downto 0);
			b:			in std_logic_vector(n-1 downto 0);
			sum:		out std_logic_vector(n-1 downto 0);
			c_out:	out std_logic);
end carry_lookahead_adder;

architecture struct_carry_lookahead_adder of carry_lookahead_adder is
	signal t_sum: std_logic_vector(n-1 downto 0);
	signal t_c_in: std_logic_vector(n-1 downto 0);
	signal t_gen: std_logic_vector(n-1 downto 0);
	signal t_prop: std_logic_vector(n-1 downto 0);
begin

	t_sum <= a xor b;
	t_gen <= a and b;
	t_prop <= a xor b;
	
	process(all)
	begin
		t_c_in(1) <= t_gen(0) or (t_prop(0) and c_in);
		for i in 1 to n-1 loop
			t_c_in(i) <= t_gen(i-1) or (t_prop(i-1) and t_c_in(i-1));
		end loop;
	end process;
	c_out <= t_gen(n-1) or (t_prop(n-1) and t_c_in(n-1));
	sum(0) <= t_sum(0) xor c_in;
	sum(n-1 downto 1) <= t_sum(n-1 downto 1) xor t_c_in(n-1 downto 1);

end struct_carry_lookahead_adder;