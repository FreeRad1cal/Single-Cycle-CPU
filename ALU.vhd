library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	port(
		alu_op				: in natural;
		input1, input2		: in std_logic_vector(31 downto 0);
		mult_in				: in std_logic_vector(63 downto 0);
		mult_out				: out std_logic_vector(63 downto 0);
		shamt					: in std_logic_vector(4 downto 0);
		output				: out std_logic_vector(31 downto 0);
		zero					: out std_logic);
end alu;

architecture struct_alu of alu is
	signal all_zeros: std_logic_vector(31 downto 0) := (others => '0');
	signal input1_signed, input2_signed: signed(31 downto 0);
	signal input1_unsigned, input2_unsigned: unsigned(31 downto 0);
	signal shamt_int: integer;
	signal product: std_logic_vector(63 downto 0);
	signal equal_temp: std_logic;
begin

input1_signed <= signed(input1);
input2_signed <= signed(input2);
input1_unsigned <= unsigned(input1);
input2_unsigned <= unsigned(input2);
shamt_int <= to_integer(unsigned(shamt));

process(all)
begin
	if input1_unsigned = input2_unsigned then
		equal_temp <= '1';
	else
		equal_temp <= '0';
	end if;
end process;

m: entity work.multiplier
	generic map(n => 32)
	port map(a => input1, b => input2, product => product);

process(all)
begin
	output <= all_zeros;
	mult_out <= product;
	zero <= equal_temp;
	case alu_op is
		when 1 => -- and
			output <= input1 and input2;
		when 2 => -- nor
			output <= input1 nor input2;
		when 3 => -- or
			output <= input1 or input2;
		when 4 => -- slt
			if input1_signed < input2_signed then
				output <= (0 => '1', others => '0');
			else
				output <= all_zeros;
			end if;
		when 12 => -- sltu
			if input1_unsigned < input2_unsigned then
				output <= (0 => '1', others => '0');
			else
				output <= all_zeros;
			end if;
		when 5 => -- add
			output <= std_logic_vector(input1_signed + input2_signed);
		when 6 => -- sll
			output <= std_logic_vector(shift_left(input2_unsigned, shamt_int));
		when 7 => -- srl
			output <= std_logic_vector(shift_right(input2_unsigned, shamt_int));
		when 8 => -- mult
			mult_out <= product;
		when 9 => -- macc
			mult_out <= std_logic_vector(unsigned(product) + unsigned(mult_in));
		when 10 => -- be
			zero <= equal_temp;
		when 11 => -- bne
			zero <= not equal_temp;
		when 13 => -- rol
			output <= std_logic_vector(rotate_left(input2_unsigned, shamt_int));
		when 14 => -- ror
			output <= std_logic_vector(rotate_right(input2_unsigned, shamt_int));
		when 15 => -- xor
			output <= input1 xor input2;
		when others =>
			null;
	end case;
end process;

end struct_alu;