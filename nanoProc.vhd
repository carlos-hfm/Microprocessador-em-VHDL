LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.ALL;
USE  IEEE.STD_LOGIC_ARITH.ALL;
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY nanoProc IS
	port(	reset	: IN STD_LOGIC;
			clock	: IN STD_LOGIC;
			ACout	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			IRout	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			PCout	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END nanoProc;

ARCHITECTURE exec OF nanoProc IS
TYPE maquinaEstados IS (inicia, le, decodifica, executa);
SIGNAL estado : maquinaestados;


COMPONENT dmemory
	PORT(	read_data 	: OUT	STD_LOGIC_VECTOR( 15 DOWNTO 0 );
        	address 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	write_data 	: IN 	STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	   	memWrite 	: IN 	STD_LOGIC;
         clock,reset	: IN 	STD_LOGIC );
END COMPONENT;

SIGNAL AC, dataBus, IR	: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL PC, addrBus		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL MW					: STD_LOGIC;

BEGIN

PROCESS (clock, reset)
    BEGIN
        IF reset = '1' THEN
            estado <= inicia;
        ELSIF clock'EVENT AND clock = '1' THEN
            CASE estado IS
                WHEN inicia => IF reset = '0' THEN estado <= le; ELSE estado <= inicia; END IF;					      
                WHEN le => IF reset = '0' THEN estado <= decodifica; ELSE estado <= inicia; END IF;					 
                WHEN decodifica => IF reset = '0' AND IR(15 DOWNTO 8) = X"04" THEN estado <= executa; ELSE estado <= le; END IF;					 
                WHEN executa => IF reset = '0' THEN estado <= le; ELSE estado <= inicia; END IF;					 
            END CASE;
        END IF;
    END PROCESS;
	
	-- Componente de memória definida no arquivo DMEMORY.vhd
	memoria : dmemory PORT MAP(	
							read_data	=> dataBus,
							address		=> addrBus,
							write_data	=> AC,
							memWrite		=> MW,
							clock			=> clock,
							reset			=> reset);
							
 -- PC, IR e AC sao registradores, portanto sensiveis ao clock
	PROCESS (clock, reset, estado)
	BEGIN
		IF (reset = '1') AND estado = inicia THEN
			-- APÓS O PROJETO O ESTADO INICIAL DEVE ZERAR OS REGISTRADORES ABAIXO
			-- O reset DEVE SOMENTE DEFINIR O ESTADO INICIAL
			PC <= X"00";
			IR <= X"0000";
			AC <= X"0000";
		ELSIF clock'EVENT AND clock = '1' AND estado = le THEN
		   AC <= "1000000000000010"; -- teste JNEG
			IR <= dataBus;
			PC <= PC + 1;
		ELSIF clock'EVENT AND clock = '1' AND estado = executa THEN
			IF AC(15) = '1' THEN 
			 PC <= IR(7 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;
	
	-- Abaixo declarar os sinais de saida (controle)
	WITH IR(15 DOWNTO 8) SELECT
	
	addrBus <= IR(7 DOWNTO 0) WHEN X"04",
				PC WHEN OTHERS;
	MW <= '0'; -- memória habilitada para leitura
	
	-- sinais a serem passados para a TLE para apresentação
	-- no display de LCD na placa
	PCout <= PC;
	IRout <= IR;
	ACout <= AC;
	
END exec;