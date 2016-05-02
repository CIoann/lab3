library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reg24b is
port(
		clk: in  std_logic;
		rst: in std_logic;
		D: in  std_logic_vector(23 downto 0);
		Q: out std_logic_vector(23 downto 0)
);
end reg24b;

architecture arc_reg of reg24b is 

--signals

begin

reg_clk: process(clk,rst)
begin
	if (rst = '0') then
		Q<= (others=>'0');
	elsif (rising_edge(clk)) then
		Q<=D;
	end if;
	
end process;

end arc_reg;
