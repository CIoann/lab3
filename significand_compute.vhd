library IEEE;
	 use IEEE.std_logic_1164.all;

entity significand_compute is
	Port (	
	
signal CLOCK: STD_logic;
SIGNAL RESET: STD_LOGIC;
	MX : In std_logic_vector (23 downto 0);
		MY : In std_logic_vector (23 downto 0);
		OVF : Out std_logic;
		Z : Out std_logic_vector (23 downto 0) );
end significand_compute;

architecture SCHEMATIC of significand_compute is

   signal       PS : std_logic_vector(47 downto 0);
   signal       PC : std_logic_vector(47 downto 0);
   signal       PROD : std_logic_vector(47 downto 0);
   signal       P1S : std_logic_vector(47 downto 0);
   signal       P1C : std_logic_vector(47 downto 0);
   signal       PROD1 : std_logic_vector(47 downto 0);
   signal       P2S : std_logic_vector(47 downto 0);
   signal       P2C : std_logic_vector(47 downto 0);
   signal       PROD2 : std_logic_vector(47 downto 0);
   signal       RBIT : std_logic_vector(48 downto 0);
   signal       GND : std_logic;

   component array24x24
        Port (  
		  
signal CLOCK: STD_logic;
SIGNAL RESET: STD_LOGIC;
		  X : In std_logic_vector (23 downto 0);
                Y : In std_logic_vector (23 downto 0);
                S : Out std_logic_vector (47 downto 0) ;
                C : Out std_logic_vector (47 downto 0) );
   end component;

   component normalize1 
        Port (  A : In std_logic_vector (47 downto 0);
                Z : Out std_logic_vector (23 downto 0) );
   end component;

      component gl_cpa 
        GENERIC(n : integer);
        Port (  A1 : In std_logic_vector (n downto 0);
                A2 : In std_logic_vector (n downto 0);
                S : Out std_logic_vector (n downto 0) );
   end component;

   component gl_csa32 is
        GENERIC(n : integer);
        Port (  A : In std_logic_vector (n downto 0);
                B : In std_logic_vector (n downto 0);
                C : In std_logic_vector (n downto 0);
                Cin : In std_logic;
                Z : Out std_logic_vector (n downto 0);
                Y : Out std_logic_vector (n downto 0) );
   end component;

   component gl_mux21 
        GENERIC(n : integer);
        Port (  A0 : In std_logic_vector (n downto 0);
                A1 : In std_logic_vector (n downto 0);
                SEL : In std_logic;
                Z : Out std_logic_vector (n downto 0) );
   end component;
	
	component reg47
port(
		clk: in  std_logic;
		rst: in std_logic;
		D: in  std_logic_vector(47 downto 0);
		Q: out std_logic_vector(47 downto 0)
);
end component;

	component reg24b
port(
		clk: in  std_logic;
		rst: in std_logic;
		D: in  std_logic_vector(23 downto 0);
		Q: out std_logic_vector(23 downto 0)
);
end component;

signal dps, dpc : std_logic_vector(47 downto 0);
signal dzz : std_logic_vector(23 downto 0);
begin

GND <= '0';
RBIT <= "0000000000000000000000000100000000000000000000000";
   I_7 : array24x24
	Port Map ( CLOCK=>CLOCK, RESET=>RESET,
	X(23 downto 0)=>MX(23 downto 0),
		   Y(23 downto 0)=>MY(23 downto 0),
		   S(47 downto 0)=>dPS(47 downto 0),
		   C(47 downto 0)=>dPC(47 downto 0)  );
reg0 : reg47 port map(clk=>CLOCK, rst=> RESET, D=> dps, Q=> PS);

reg1 : reg47 port map(clk=>CLOCK, rst=> RESET, D=> dpc, Q=> PC);

   CSA1 : gl_csa32 Generic Map(n=>47)
        Port Map ( A=> PS, B=> PC, C=> RBIT(48 downto 1), Cin=> GND, 				   Z=>P1s , Y=>P1c);

   CSA2 : gl_csa32 Generic Map(n=>47)
        Port Map ( A=> PS, B=> PC, C=> RBIT(47 downto 0), Cin=> GND, 				   Z=>P2s , Y=>P2c);


   A_1 : gl_cpa Generic Map(n=>47)
        Port Map ( A1 => P1S, A2  => P1C, S => PROD1 );

   A_2 : gl_cpa Generic Map(n=>47)
        Port Map ( A1 => P2S, A2  => P2C, S => PROD2 );

   A_MUX : gl_mux21 Generic Map(n=>23)
        Port Map ( A0 => PROD1(46 downto 23), A1  => PROD2(47 downto 24), 
		   SEL => PROD2(47), Z => dzz );

reg3 : reg24b port map(clk=>CLOCK, rst=> RESET, D=> dzz, Q=> Z);


OVF<=PROD2(47);

end SCHEMATIC;

configuration CFG_significand_compute_SCHEMATIC of significand_compute is

   for SCHEMATIC
      for I_7: array24x24
         use configuration WORK.CFG_array24x24_SCHEMATIC;
      end for;
      for A_1, A_2: gl_cpa
         use configuration WORK.CFG_gl_cpa_BEHAVIORAL;
      end for;
      for CSA1, CSA2 : gl_csa32
         use configuration WORK.CFG_gl_csa32_BEHAVIORAL;
      end for;
      for A_MUX : gl_mux21
         use configuration WORK.CFG_gl_mux21_BEHAVIORAL;
      end for;
   end for;

end CFG_significand_compute_SCHEMATIC;
