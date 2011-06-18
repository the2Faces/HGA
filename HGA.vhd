-- Komment!

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY HGA IS

PORT
(
	KMM, KOM, MIL, E_STOP : IN STD_LOGIC;
	KAV, MIV : OUT STD_LOGIC;
	clk : IN STD_LOGIC;
	START , out_50_50 : OUT STD_LOGIC;
	A_STOP, POR : IN STD_LOGIC
);

END ENTITY HGA;

ARCHITECTURE beh OF HGA IS

TYPE states IS (IGZ,KMMs, KOMs, MILs, MIo, KAo);
SIGNAL current_state, next_state : states;
SIGNAL reset : STD_LOGIC;
reset <= NOT E_STOP;
SIGNAL butEN, KMMi, KOMi, MILi, short : STD_LOGIC;

BEGIN
	next_state_register : PROCESS (clk, reset)
		IF (Reset = '1') THEN
			current_state <= IGZ;
		ELSIF (Clock'EVENT AND Clolck = '1') THEN
			current_state <= next_state;
		END IF;
	END PROCESS next_state_register;
	
	next_state_logc : PROCESS (KMMi, KOMi, MILi, A_STOP, short, current_state)
	BEGIN
		CASE current_state IS
			WHEN IGZ =>
				IF KMMi = 1 THEN
					next_state = KMMs;
				ELSIF KOMi = 1 THEN
					next_state = KOMs;
				ELSIF MILi = 1 THEN
					next_state = MILs;
				ELSE
					next_state = IGZ;
				END IF;
				
			WHEN KMMs =>
				next_state = MIo;
			
			WHEN KOMs =>
				next_state = KAo;
			
			WHEN MILs =>
				next_state = MIo;
			
			WHEN MIo =>
				IF (A_STOP = '0') AND (short = '1')
					next_state = KAo;
				ELSIF (A_STOP = '0') AND (short = '0')
					next_state = IGZ;
				ELSE
					next_state = MIo;
				END IF;
				
			WHEN KAo =>
				IF A_STOP = '0'
					next_state = IGZ;
				ELSE
					next_state = KAo;
				END IF;
				
		END CASE;
	END PROCESS next_state_logc;
	
	output_logic : PROCESS (current_state)
	BEGIN
		butEN = '0';
		KAV <= '0';
		MIV <= '0';
		CASE current_state IS
			WHEN IGZ
				butEN = '1';
				short <= '0';
				START <= '0';
			WHEN KMMs
				short <= '1';
				START <= '1';
			WHEN KOMs
				START <= '1';
			WHEN MILs
				START <= '1';
			WHEN MIo
				START <= '0';
				MIV <= '1';
			WHEN KAo
				START <= '0';
				KAV <= '1';
		END CASE;
	END PROCESS output_logic;
	
out_50_50 <= short;
KMMi <= KMM AND butEN;
KOMi <= KOM AND butEN;
MILi <= KOM AND butEN;

END ARCHITECTURE beh;