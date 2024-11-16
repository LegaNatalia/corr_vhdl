
LIBRARY IEEE;--! standard library IEEE (Institute of Electrical and Electronics Engineers)
USE IEEE.std_logic_1164.ALL;--! standard unresolved logic UX01ZWLH-
USE IEEE.numeric_std.ALL;--! for the signed, unsigned types and arithmetic ops

entity hello_TOP is
PORT (
  refclk : IN STD_LOGIC;--! reference clock expect 250Mhz
  rst    : IN STD_LOGIC--! sync active high reset. sync -> refclk
);
end entity hello_TOP;
architecture rtl of hello_TOP is
begin
  --тут можно как раз всё объединить :)))
end architecture rtl;
