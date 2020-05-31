library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
	generic(
		size: natural := 32);
	port(
		clock, reset, write		: in std_logic;
		reg1, reg2, reg3, regw	: in std_logic_vector(4 downto 0) := (others => '0'); -- reg3 for testing only
		dataw							: in std_logic_vector(size-1 downto 0);
		data1, data2, data3		: out std_logic_vector(size-1 downto 0));
end register_file;

architecture struct_register_file of register_file is
	type register_vector is array(integer range 31 downto 0) of std_logic_vector(size-1 downto 0);
	
	signal registers: register_vector;
	signal reg1_index, reg2_index, reg3_index, regw_index: natural;
begin

reg1_index <= to_integer(unsigned(reg1));
reg2_index <= to_integer(unsigned(reg2));
reg3_index <= to_integer(unsigned(reg3));
regw_index <= to_integer(unsigned(regw));

f: for i in registers'range generate
begin
	process(all)
	begin
		if rising_edge(clock) then
			if reset = '1' then
				registers(i) <= (others => '0');
			elsif regw_index = i and write = '1' then
				registers(i) <= dataw;
			else
				registers(i) <= registers(i);
			end if;
		end if;
	end process;
end generate f;

data1 <= registers(reg1_index);
data2 <= registers(reg2_index);
data3 <= registers(reg3_index);

end struct_register_file;