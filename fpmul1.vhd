library IEEE;
	 use IEEE.std_logic_1164.all;

entity fpmul1 is
	Port (	A1 : In std_logic_vector (31 downto 0);
		A2 : In std_logic_vector (31 downto 0);
		CLOCK : In std_logic;
		RESET : In std_logic;
		Z : Out std_logic_vector (31 downto 0) );
end fpmul1;

architecture SCHEMATIC of fpmul1 is

   signal       BX : std_logic_vector(31 downto 0);
   signal       BY : std_logic_vector(31 downto 0);
   signal       MX : std_logic_vector(23 downto 0);
   signal       MY : std_logic_vector(23 downto 0);
   signal       MZ : std_logic_vector(23 downto 0);
   signal       EXP : std_logic_vector(7 downto 0);
   signal       EXP1 : std_logic_vector(7 downto 0);
   signal       EZ : std_logic_vector(7 downto 0);
   signal       OVF : std_logic;
   signal       SZ : std_logic;


   component reg32b
	Port (	A : In std_logic_vector (31 downto 0);
		CLOCK : In std_logic;
		RESET : In std_logic;
		Z : Out std_logic_vector (31 downto 0) );
   end component;
	
	
	component reg1b 
	port(
			clk: in  std_logic;
			rst: in std_logic;
			D: in  std_logic;
			Q: out std_logic
	);
	end component;
	
	component reg8b
	port(
			clk: in  std_logic;
			rst: in std_logic;
			D: in  std_logic_vector(7 downto 0);
			Q: out std_logic_vector(7 downto 0)
	);
	end component;

   component out_sign
        Port (  sX   : In std_logic;
                sY   : In std_logic;
                SZ : Out std_logic );
   end component;

   component expadd
        Port (  A1 : In std_logic_vector (7 downto 0);
                A2 : In std_logic_vector (7 downto 0);
                S : Out std_logic_vector (7 downto 0) );
   end component;

   component expupdate
	Port (  EXP : In std_logic_vector (7 downto 0);
                OVF : In std_logic;
                EZ : Out std_logic_vector (7 downto 0) );
   end component;

   component  expincrement is
        Port (  EXP : In std_logic_vector (7 downto 0);
                EZ : Out std_logic_vector (7 downto 0) );
   end component;


   component significand_compute 
	
        Port (  
		  
signal CLOCK: STD_logic;
SIGNAL RESET: STD_LOGIC;
		  MX : In std_logic_vector (23 downto 0);
                MY : In std_logic_vector (23 downto 0);
                OVF : Out std_logic;
                Z : Out std_logic_vector (23 downto 0) );
   end component;

   component gl_mux21 
        GENERIC(n : integer);
        Port (  A0 : In std_logic_vector (n downto 0);
                A1 : In std_logic_vector (n downto 0);
                SEL : In std_logic;
                Z : Out std_logic_vector (n downto 0) );
   end component;
signal Din_sz:std_logic;
signal Din_ez : std_logic_vector(7 downto 0);

begin

   I_1 : reg32b
	Port Map ( A(31 downto 0)=>A1(31 downto 0), CLOCK=>CLOCK,
		 RESET=>RESET, Z(31 downto 0)=>BX(31 downto 0) );
   I_2 : reg32b
	Port Map ( A(31 downto 0)=>A2(31 downto 0), CLOCK=>CLOCK,
		 RESET=>RESET, Z(31 downto 0)=>BY(31 downto 0) );

   I_4 : expadd
	Port Map ( A1(7 downto 0)=>BX(30 downto 23), 
		   A2(7 downto 0)=>BY(30 downto 23),
		   S(7 downto 0)=>EXP(7 downto 0) ); 
   I_6 : expincrement
	Port Map ( EXP(7 downto 0)=>EXP(7 downto 0), 
		   EZ(7 downto 0)=>EXP1(7 downto 0) );

   -- must include inplicit 1
   MX(23)<='1'; MX(22 downto 0) <= BX(22 downto 0); 
   MY(23)<='1'; MY(22 downto 0) <= BY(22 downto 0); 

   I_5 : significand_compute
	Port Map (CLOCK=>CLOCK, RESET=>RESET, MX=>MX, MY=>MY, OVF=>OVF, Z=>MZ );

   EXP_MUX : gl_mux21 Generic Map(n=>7)
        Port Map ( A0 => EXP, A1  => EXP1, SEL => OVF, Z => Din_ez );
		  
   st_exp_mux : reg8b port map(clk=>CLOCK, rst=>RESET,D=>Din_ez, Q=> EZ);



   I_7 : out_sign
	Port Map (  SX=>BX(31), SY=>BY(31), SZ=>Din_sz );
	
	st_out_sign: reg1b port map(clk=>CLOCK, rst=>RESET, D => Din_sz, Q => SZ);
   I_3 : reg32b
	Port Map ( A(31)=>SZ,
		   A(30 downto 23)=>EZ(7 downto 0), 
		   A(22 downto 0)=>MZ(22 downto 0), 
		   CLOCK=>CLOCK, RESET=>RESET, 
                   Z(31 downto 0)=>Z(31 downto 0) );

end SCHEMATIC;

configuration CFG_FPMUL1_SCHEMATIC of FPMUL1 is

   for SCHEMATIC
      for I_1, I_2, I_3: reg32b
         use configuration WORK.CFG_reg32b_BEHAVIORAL;
      end for;
      for I_4: expadd
         use configuration WORK.CFG_expadd_BEHAVIORAL;
      end for;
      for I_5: significand_compute
         use configuration WORK.CFG_significand_compute_SCHEMATIC;
      end for;
      for I_6: expincrement
         use configuration WORK.CFG_expincrement_BEHAVIORAL;
      end for;
      for I_7: out_sign 
         use configuration WORK.CFG_out_sign_BEHAVIORAL;
      end for;
      for EXP_MUX : gl_mux21
         use configuration WORK.CFG_gl_mux21_BEHAVIORAL;
      end for;

   end for;

end CFG_FPMUL1_SCHEMATIC;
