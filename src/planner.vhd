LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

entity planner is

PORT (
  refclk           : IN STD_LOGIC;--! reference clock expect 250Mhz
  rst              : IN STD_LOGIC;--! sync active high reset. sync -> refclk
  read_complete    : IN STD_LOGIC;--! when data(seq\ref) is reading
  corr_DONE        : IN STD_LOGIC;--! когда корреляция завершилось (принимаем этот сигнал от коррелятора, когда он закончил обработку)
  axi_address      : OUT STD_LOGIC_VECTOR(31 downto 0); --! 
  axi_enabl        : OUT STD_LOGIC;
  flag             : OUT STD_LOGIC;
  corr_enable      : OUT STD_LOGIC;
  buff_ref         : IN STD_LOGIC; --! пустой ли буфер для референса
  buff_seq         : IN STD_LOGIC --! пустой ли буфер для последовательности
);
end entity planner;

architecture planner of planner is
--! state machine
type state is (idle, read_seq, read_ref, corr);
signal fsm : state; 

begin
clk_main: process(refclk, rst)
begin
if rst = '0' then
    fsm <= idle; 
    axi_address<= "00000000";
    axi_enable<='0';
    flag <='0';
    corr_enable <='0';
elsif rising_edge(refclk) then

 case fsm is 
    when idle =>
        axi_address<= (others => '0');;
        axi_enable<='0';
        flag <='0';
        corr_enable <='0';
        if (buff_ref & buff_seq = 1) then
            fsm <= read_seq;
        end if; 
    when read_seq =>
        axi_address<= "00100000001000000010000000100000"; --! i don`t know :()
        axi_enable<='1';
        flag <='1'; --! seq flag
        if (read_complete = '1') then --! мастер считал нужное кол-во данных
            fsm <= read_ref; 
            axi_enable <= '0';
        end if;
    when read_ref =>
        axi_address<= "00100000001000000110001000101000"; --! i don`t know :()
        axi_enable<='1';
        flag <='0'; --! ref flag
        if (read_complete = '1') then --! мастер считал нужное кол-во данных
            fsm <= corr;
            
        end if;
        
    when corr =>
        if(from_master_DONE = '1') then
            corr_enable <= '1';
            fsm <= idle; 
        end if;
    when others =>fsm <= idle; 
    end case;
end if;
end process;

end architecture planner;
