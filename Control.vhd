library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control is
	port(
		opcode, funct: in std_logic_vector(5 downto 0);
		reg_dst, branch, mem_to_reg, mem_write, alu_src, 
			reg_write, mult_hi, mult_lo, mult_write, sign_ext: out std_logic;
		alu_op: out natural);
end control;

architecture struct_control of control is

signal opcode_int, funct_int: integer;

begin

-- {1: and, 2: nor, 3: or, 4: slt, 5: add, 6: sll, 7: srl, 8: mult, 9: macc, 10: be, 11: bne, 12: sltu, 13: rol, 14: ror, 15: xor}
-- reg_dst = 1 if I-type, = 0 if R-type 
-- alu_src = 1 if I-type, = 0 if R-type

opcode_int <= to_integer(unsigned(opcode));
funct_int <= to_integer(unsigned(funct));

process(all)
begin
	if opcode_int = 0 then -- R-type
		reg_dst <= '0';
		alu_src <= '0';
	else -- I-type
		reg_dst <= '1';
		alu_src <= '1';
	end if;
	
	alu_op <= 0;
	reg_write <= '1';
	branch <= '0';
	mem_to_reg <= '0';
	mem_write <= '0';
	mult_hi <= '0';
	mult_lo <= '0';
	mult_write <= '0';
	sign_ext <= '0';
	
	case opcode_int is
		when 0 =>
			case funct_int is
				when 16#24# => -- and
					alu_op <= 1;
				when 16#27# => -- nor
					alu_op <= 2;
				when 16#25# => -- or
					alu_op <= 3;
				when 16#2b# => -- sltu
					alu_op <= 12;
				when 16#20# => -- add
					alu_op <= 5;
				when 16#2a# => -- slt
					alu_op <= 4;
				when 16#10# => -- mfhi
					mult_hi <= '1';
				when 16#12# => -- mflo
					mult_lo <= '1';
				when 0 => -- sll
					alu_op <= 6;
				when 2 => -- srl
					alu_op <= 7;
				when 3 => -- rol
					alu_op <= 13;
				when 4 => -- ror
					alu_op <= 14;
				when 16#18# => -- mult
					alu_op <= 8;
					mult_write <= '1';
					reg_write <= '0';
				when 16#19# => -- macc
					alu_op <= 9;
					mult_write <= '1';
					reg_write <= '0';
				when 16#2c# => -- xor
					alu_op <= 15;
				when others =>
					alu_op <= 0;
			end case;
		when 16#a# => -- slti
			alu_op <= 4;
			sign_ext <= '1';
		when 16#b# => -- sltiu
			alu_op <= 4;
		when 16#d# => -- ori
			alu_op <= 3;
		when 8 => -- addi
			alu_op <= 5;
			sign_ext <= '1';
		when 9 => -- mult
			alu_op <= 8;
			sign_ext <= '1';
			reg_write <= '0';
		when 16#e# => -- macci
			alu_op <= 9;
			mult_write <= '1';
			reg_write <= '0';
			sign_ext <= '1';
		when 16#11# => -- be
			alu_op <= 10;
			branch <= '1';
			reg_write <= '0';
		when 16#12# => -- bne
			alu_op <= 11;
			branch <= '1';
			reg_write <= '0';
		when 16#13# => -- lw
			alu_op <= 5;
			mem_to_reg <= '1';
			sign_ext <= '1';
		when 16#14# => -- sw
			alu_op <= 5;
			mem_write <= '1';
			sign_ext <= '1';
			reg_write <= '0';
		when others =>
			null;
	end case;
end process;

end struct_control;