LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.ALL;

ENTITY TLE_Proc IS
	port(	reset	: IN STD_LOGIC;
			clock48MHz	: IN STD_LOGIC; 		-- clock apenas do LCD, não é o mesmo do sistema 
			LCD_RS, LCD_E	: OUT STD_LOGIC;	-- sinais de controle do display
			LCD_RW, LCD_ON	: OUT STD_LOGIC;	-- sinais de controle do display
			INFO	: INOUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- informações formatadas p/ display
			Instr_AC	: IN STD_LOGIC ; 	-- sinal que seleciona entre mostrar IR ou AC no display
			clockPB	: IN STD_LOGIC);	-- sinal para fazer negar o clock
END TLE_Proc;

ARCHITECTURE apres OF TLE_Proc IS

COMPONENT LCD_Display
	GENERIC(Num_Hex_Digits: Integer:= 11);
	PORT(	reset, clk_48Mhz	: IN	STD_LOGIC;
			Hex_Display_Data	: IN  STD_LOGIC_VECTOR((Num_Hex_Digits*4)-1 DOWNTO 0);
			LCD_RS, LCD_E		: OUT	STD_LOGIC;
			LCD_RW				: OUT STD_LOGIC;
			DATA_BUS				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0));
END COMPONENT;

COMPONENT nanoProc
	port(	reset	: IN STD_LOGIC;
			clock	: IN STD_LOGIC;
			ACout	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			IRout	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			PCout	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END COMPONENT;

SIGNAL HexDisplayData : STD_LOGIC_VECTOR(43 DOWNTO 0);
SIGNAL clock			: STD_LOGIC;
SIGNAL addr				: STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL data				: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL dspData			: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL AC, IR			: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL PC				: STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

	proc: nanoProc
	PORT MAP(
		reset	=> reset,
		clock	=> clock,
		ACout	=> AC,
		IRout	=> IR,
		PCout	=> PC);
						
	lcd: LCD_Display
	PORT MAP(
		reset				=> reset,
		clk_48Mhz		=> clock48MHz,
		Hex_Display_Data	=> HexDisplayData,
		LCD_RS			=> LCD_RS,
		LCD_E				=> LCD_E,
		LCD_RW			=> LCD_RW,
		DATA_BUS			=> INFO);
		
	-- Inverte o sinal de clock para usar o pushbutton da placa como clock
	clock <= NOT clockPB;
	-- Liga o display
	LCD_ON <= '1';
	-- Ajusta o tamanho dos sinais de endereço e dado para o display
	addr <= "0000" & PC;
	data <= x"0000" & DspData;
	-- Define o que será apresentado no display
	DspData <= 	IR  WHEN Instr_AC='0' ELSE
					AC;
	HexDisplayData <= addr & data;

END apres;