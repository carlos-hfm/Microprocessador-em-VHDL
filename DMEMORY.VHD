--  Módulo Dmemory implementa a memoria de dados e instrução
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY dmemory IS
	PORT(	read_data 	: OUT	STD_LOGIC_VECTOR( 15 DOWNTO 0 );
        	address 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	write_data 	: IN 	STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	   	memWrite 	: IN 	STD_LOGIC;
         clock,reset	: IN 	STD_LOGIC );
END dmemory;

ARCHITECTURE behavior OF dmemory IS
SIGNAL write_clock : STD_LOGIC;
BEGIN
	data_memory : altsyncram
	GENERIC MAP  (
		operation_mode => "SINGLE_PORT",
		width_a => 16,
		widthad_a => 8,
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "program.mif",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		wren_a => memwrite,
		clock0 => write_clock,
		address_a => address,
		data_a => write_data,
		q_a => read_data	);
		
		-- dependendo das opções de projeto pode ser indicado inverter 
		-- o clock da memória em relação ao clock de controle de estado.
		-- Neste caso faça write_clock <= NOT clock.
		write_clock <= NOT clock;
END behavior;

