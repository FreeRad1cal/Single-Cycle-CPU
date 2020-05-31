library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decoder is
	port(
		instruction			: in std_logic_vector(31 downto 0);
		opcode, funct		: out std_logic_vector(5 downto 0);
		rs, rt, rd, shamt	: out std_logic_vector(4 downto 0);
		imm16					: out std_logic_vector(15 downto 0));
end instruction_decoder;

architecture struct_instruction_decoder of instruction_decoder is

begin

opcode <= instruction(31 downto 26);
rs <= instruction(25 downto 21);
rt <= instruction(20 downto 16);
rd <= instruction(15 downto 11);
imm16 <= instruction(15 downto 0);

end struct_instruction_decoder;