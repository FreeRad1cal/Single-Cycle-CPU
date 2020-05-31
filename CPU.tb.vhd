library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instructions_tb is
end instructions_tb;

architecture arch of instructions_tb is
	
	constant period: time := 20 ns;
	
	signal clock: std_logic;
	signal ext_program: std_logic;
	signal ext_instr_ram_data, ext_data_ram_write_data: std_logic_vector(31 downto 0);
	signal ext_instr_ram_address, ext_data_ram_write_address: std_logic_vector(7 downto 0);
	signal ext_pc: std_logic_vector(7 downto 0);
	signal ext_reg_file_data: std_logic_vector(31 downto 0);
	signal ext_reg_file_reg: std_logic_vector(4 downto 0);
	
begin

	sut: entity work.cpu
		port map(clock => clock, ext_program => ext_program, ext_instr_ram_data => ext_instr_ram_data, 
		ext_data_ram_write_data => ext_data_ram_write_data, ext_instr_ram_address => ext_instr_ram_address, 
		ext_data_ram_write_address => ext_data_ram_write_address, ext_pc => ext_pc, 
		ext_reg_file_reg => ext_reg_file_reg);
	
	process
	begin
		clock <= '0';
		wait for period/2;
		clock <= '1';
		wait for period/2;
	end process;

	process
	begin	
		ext_program <= '1';
		
		for i in 0 to 9 loop
			ext_data_ram_write_address <= std_logic_vector(to_unsigned(i*4, 8));
			ext_data_ram_write_data <= std_logic_vector(to_unsigned(i, 32));
			wait for period;
		end loop;
		
		-- xor $1 $1 $1
		ext_instr_ram_address <= std_logic_vector(to_unsigned(0, 8));
		ext_instr_ram_data <= "00000000001000010000100000101100";
		wait for period;
		
		-- xor $3 $3 $3
		ext_instr_ram_address <= std_logic_vector(to_unsigned(4, 8));
		ext_instr_ram_data <= "00000000011000110001100000101100";
		wait for period;
		
		-- addi $0 $2 5
		ext_instr_ram_address <= std_logic_vector(to_unsigned(8, 8));
		ext_instr_ram_data <= "00100000000000100000000000000101";
		wait for period;
		
		-- be $1 $2 24
		ext_instr_ram_address <= std_logic_vector(to_unsigned(12, 8));
		ext_instr_ram_data <= "01000100001000100000000000011000";
		wait for period;
		
		-- lw 0($1) $4
		ext_instr_ram_address <= std_logic_vector(to_unsigned(16, 8));
		ext_instr_ram_data <= "01001100001001000000000000000000";
		wait for period;
		
		-- lw 20($1) $5
		ext_instr_ram_address <= std_logic_vector(to_unsigned(20, 8));
		ext_instr_ram_data <= "01001100001001010000000000010100";
		wait for period;
		
		-- macc $4 $5
		ext_instr_ram_address <= std_logic_vector(to_unsigned(24, 8));
		ext_instr_ram_data <= "00000000100001010000000000011001";
		wait for period;
		
		-- addi $1 $1 1
		ext_instr_ram_address <= std_logic_vector(to_unsigned(28, 8));
		ext_instr_ram_data <= "00100000001000010000000000000001";
		wait for period;
		
		-- mflo $6
		ext_instr_ram_address <= std_logic_vector(to_unsigned(32, 8));
		ext_instr_ram_data <= "00000000000000000011000000010010";
		wait for period;
		
		-- be $0 $0 -28
		ext_instr_ram_address <= std_logic_vector(to_unsigned(36, 8));
		ext_instr_ram_data <= "01000000000000101111111111100100";
		wait for period;
		
		-- end of program
		ext_instr_ram_address <= std_logic_vector(to_unsigned(40, 8));
		ext_instr_ram_data <= "00000000000000000000000000000000";
		wait for period;
		
		ext_pc <= std_logic_vector(to_unsigned(0, 8));
		ext_reg_file_reg <= "00001";
		
		ext_program <= '0';
		
		wait for period*38;
		
		assert ext_reg_file_data = "00000000000000000000000001010000" report "Bad result";
		
	end process;
	 
end arch;
