LIBRARY IEEE;--! standard library IEEE (Institute of Electrical and Electronics Engineers)
USE IEEE.std_logic_1164.ALL;--! standard unresolved logic UX01ZWLH-
USE IEEE.numeric_std.ALL;--! for the signed, unsigned types and arithmetic ops

entity bram_buf is
PORT (
  refclk : IN STD_LOGIC;--! reference clock expect 250Mhz
  rst    : IN STD_LOGIC;--! sync active high reset. sync -> refclk

  addr   : IN STD_LOGIC_VECTOR(3 downto 0); -- адрес ячейки в буфере (от 0 до 14)
  re     : IN STD_LOGIC;                    -- read enable
  we     : IN STD_LOGIC;                    -- write enable (поднять для записи)

  data_i : IN STD_LOGIC_VECTOR(31 downto 0);    -- data input
  data_o : OUT STD_LOGIC_VECTOR(31 downto 0);   -- data output
  valid  : OUT STD_LOGIC;

);
end entity bram_buf;

architecture rtl of bram_buf is
    type mem_array_t is array (14 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
    signal memory : mem_array_t := (OTHERS => 32B"0");
begin
    process (refclk) 
    begin
        if (rising_edge(refclk)) then
            if (rst) then
                memory <= (OTHERS => 32B"0");
                valid <= '0';
            end if;
            if (we) then
                memory(to_integer(addr)) <= data(i);
                valid <= '0';
            elsif (re) then
                data_o <= memory(to_integer(addr));
                valid <= '1';
            end if;
        end if;
    end process
end architecture rtl;