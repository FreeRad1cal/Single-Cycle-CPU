library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_ram is
	generic(
		size_bytes: natural := 512;
		word_bytes: natural := 4);
	port(
		clock: in std_logic;
		write: in std_logic;
		write_address, read_address1, read_address2: in natural := 0;
		data_in: in std_logic_vector(8*word_bytes-1 downto 0);
		data_out1, data_out2: out std_logic_vector(8*word_bytes-1 downto 0));
end entity sync_ram;

architecture arch_sync_ram of sync_ram is
   signal ram: std_logic_vector(size_bytes*8-1 downto 0) := (others => '0');
begin

process(all) is
	begin
		if rising_edge(clock) and write = '1' then
			ram(write_address*8 + word_bytes*8 - 1 downto write_address*8) <= data_in;
		end if;
	end process;

  data_out1 <= ram(read_address1*8 + word_bytes*8 - 1 downto read_address1*8);
  data_out2 <= ram(read_address2*8 + word_bytes*8 - 1 downto read_address2*8);

end architecture arch_sync_ram;