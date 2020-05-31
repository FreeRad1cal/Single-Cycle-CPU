library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
	port(
		clock: in std_logic;
		ext_program: in std_logic;
		ext_instr_ram_data, ext_data_ram_write_data: in std_logic_vector(31 downto 0);
		ext_instr_ram_address, ext_data_ram_write_address: in std_logic_vector(7 downto 0);
		ext_pc: in std_logic_vector(7 downto 0);
		ext_reg_file_data: out std_logic_vector(31 downto 0);
		ext_reg_file_reg: in std_logic_vector(4 downto 0));
end cpu;

architecture struct_cpu of cpu is

signal data_ram_write: boolean;
signal instruction_ram_data_out, data_ram_data_in, data_ram_data_out: std_logic_vector(31 downto 0);
signal data_ram_read_address, data_ram_write_address: natural; 

signal pc: natural := 1;
signal mult_reg: std_logic_vector(63 downto 0) := (others => '0');

signal opcode, funct: std_logic_vector(5 downto 0);
signal rs, rt, rd, shamt: std_logic_vector(4 downto 0);
signal imm16: std_logic_vector(15 downto 0);

signal sign_ext_imm: signed(31 downto 0);
signal zero_ext_imm: unsigned(31 downto 0);

signal reg_dst, branch, mem_read, mem_to_reg, sign_ext,
	mem_write, alu_src, reg_write, mult_hi, mult_lo, mult_write: std_logic;
signal alu_op: natural;

signal reg_file_reg1, reg_file_reg2, reg_file_regw: std_logic_vector(4 downto 0);
signal reg_file_data1, reg_file_data2, reg_file_dataw: std_logic_vector(31 downto 0);

signal alu_input2, alu_output: std_logic_vector(31 downto 0);
signal alu_mult_out: std_logic_vector(63 downto 0);
signal alu_zero: std_logic;
signal alu_output_int: natural;

begin
	
	instruction_ram: entity work.sync_ram
		port map(clock => clock, write => ext_program, write_address => to_integer(unsigned(ext_instr_ram_address)), 
			read_address1 => pc, data_in => ext_instr_ram_data,
			data_out1 => instruction_ram_data_out);
	
	data_ram: entity work.sync_ram
		port map(clock => clock, write => mem_write or ext_program, 
		write_address => data_ram_write_address, read_address1 => alu_output_int, data_in => data_ram_data_in, 
		data_out1 => data_ram_data_out);
	
	instr_dec: entity work.instruction_decoder
		port map(instruction => instruction_ram_data_out, opcode => opcode, funct => funct, rs => rs, rt => rt, rd => rd, 
			shamt => shamt, imm16 => imm16);
	
	control: entity work.control
		port map(opcode => opcode, funct => funct, reg_dst => reg_dst, branch => branch,
			mem_to_reg => mem_to_reg, mem_write => mem_write, alu_src => alu_src, reg_write => reg_write, 
			mult_hi => mult_hi, mult_lo => mult_lo, mult_write => mult_write, alu_op => alu_op, sign_ext => sign_ext);
	
	register_file: entity work.register_file 
		generic map(size => 32)
		port map(clock => clock, reset => '0', write => reg_write and not ext_program, reg1 => rs, reg2 => rt,
			regw => reg_file_regw, dataw => reg_file_dataw, data1 => reg_file_data1, data2 => reg_file_data2,
			reg3 => ext_reg_file_reg, data3 => ext_reg_file_data);
	
	alu: entity work.alu
		port map(alu_op => alu_op, input1 => reg_file_data1, input2 => alu_input2, mult_in => mult_reg,
			mult_out => alu_mult_out, shamt => shamt, output => alu_output, zero => alu_zero);
	
	alu_output_int <= to_integer(unsigned(alu_output));
	
	process(all)
	begin
		if ext_program = '1' then
			data_ram_write_address <= to_integer(unsigned(ext_data_ram_write_address));
			data_ram_data_in <= ext_data_ram_write_data;
		else
			data_ram_write_address <= pc;
			data_ram_data_in <= reg_file_data2;
		end if;
	end process;
	
	-- immediate extender
	sign_ext_imm <= resize(signed(imm16), 32);
	zero_ext_imm <= resize(unsigned(imm16), 32);
	
	-- next address logic
	process(all)
	begin
		if rising_edge(clock) then
			if ext_program = '1' then
				pc <= to_integer(unsigned(ext_pc));
			elsif branch = '1' and alu_zero = '1' then
				pc <= pc + 4 + to_integer(signed(sign_ext_imm(31 downto 2) & "00"));
			else
				pc <= pc + 4;
			end if;
		end if;
	end process;
	
	-- multiplication register
	process(all)
	begin
		if rising_edge(clock) and ext_program = '0' and mult_write = '1' then
			mult_reg <= alu_mult_out;
		end if;
	end process;
	
	process(all)
	begin
		if reg_dst = '0' then -- R-type
			reg_file_regw <= rd;
		else -- I-type
			reg_file_regw <= rt;
		end if;
		
		if alu_src = '0' then -- R-type
			alu_input2 <= reg_file_data2;
		elsif sign_ext = '0' then -- I-type
			alu_input2 <= std_logic_vector(zero_ext_imm);
		else
			alu_input2 <= std_logic_vector(sign_ext_imm);
		end if;
		
		if mem_to_reg = '1' then
			reg_file_dataw <= data_ram_data_out;
		elsif mult_hi = '1' then
			reg_file_dataw <= mult_reg(63 downto 32);
		elsif mult_lo = '1' then
			reg_file_dataw <= mult_reg(31 downto 0);
		else
			reg_file_dataw <= alu_output;
		end if;
	end process;
	
end struct_cpu;