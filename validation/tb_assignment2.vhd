library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_assignment2 is
end entity;

architecture test of tb_assignment2 is
    signal logic_inputs : std_logic_vector(3 downto 0) := (others => '0');
    signal and_result, or_result : std_logic;
    signal mux_inputs : std_logic_vector(7 downto 0) := (others => '0');
    signal mux_select : std_logic_vector(2 downto 0) := (others => '0');
    signal mux_result : std_logic;
    signal letter_select : std_logic_vector(2 downto 0) := (others => '0');
    signal letter_segments : std_logic_vector(7 downto 0);
    signal votes25 : std_logic_vector(24 downto 0) := (others => '0');
    signal majority : std_logic;
    signal votes13 : std_logic_vector(12 downto 0) := (others => '0');
    signal enabled : std_logic := '0';
    signal count_segments : std_logic_vector(7 downto 0);
    type masks_type is array(natural range <>) of std_logic_vector(7 downto 0);
    constant letter_masks : masks_type(0 to 7) :=
        (x"FA", x"3E", x"1A", x"7A", x"8E", x"F6", x"00", x"00");
    constant count_masks : masks_type(0 to 13) :=
        (x"FC", x"60", x"DA", x"F2", x"66", x"B6", x"BE",
         x"E0", x"FE", x"F6", x"EE", x"3E", x"9C", x"7A");
begin
    logic_dut : entity work.logic_test
        port map(logic_inputs(3), logic_inputs(2), logic_inputs(1), logic_inputs(0),
                 and_result, or_result);
    mux_dut : entity work.mux8_1
        port map(mux_inputs(0), mux_inputs(1), mux_inputs(2), mux_inputs(3),
                 mux_inputs(4), mux_inputs(5), mux_inputs(6), mux_inputs(7),
                 mux_select, mux_result);
    letters_dut : entity work.seg7_letters
        port map(letter_select, letter_segments);
    majority_dut : entity work.vote25
        port map(votes25, majority);
    count_dut : entity work.vote13_display
        port map(votes13, enabled, count_segments);

    stimulus : process
        variable input_bits : std_logic_vector(7 downto 0);
        variable vote_bits : std_logic_vector(24 downto 0);
        variable remainder, population : integer;
    begin
        for value in 0 to 15 loop
            logic_inputs <= std_logic_vector(to_unsigned(value, 4));
            wait for 1 ns;
            if value = 15 then
                assert and_result = '1' report "AND failure input=" & integer'image(value) severity failure;
            else
                assert and_result = '0' report "AND failure input=" & integer'image(value) severity failure;
            end if;
            if value = 0 then
                assert or_result = '0' report "OR failure input=0" severity failure;
            else
                assert or_result = '1' report "OR failure input=" & integer'image(value) severity failure;
            end if;
        end loop;
        report "PASS logic_test: 16 input combinations" severity note;

        for value in 0 to 255 loop
            input_bits := std_logic_vector(to_unsigned(value, 8));
            mux_inputs <= input_bits;
            for selected in 0 to 7 loop
                mux_select <= std_logic_vector(to_unsigned(selected, 3));
                wait for 1 ns;
                assert mux_result = input_bits(selected)
                    report "MUX failure input=" & integer'image(value) & " select=" & integer'image(selected)
                    severity failure;
            end loop;
        end loop;
        report "PASS mux8_1: 2048 data/select combinations" severity note;

        for selected in 0 to 7 loop
            letter_select <= std_logic_vector(to_unsigned(selected, 3));
            wait for 1 ns;
            assert letter_segments = letter_masks(selected)
                report "Letter failure select=" & integer'image(selected) severity failure;
        end loop;
        report "PASS seg7_letters: 8 selections, including 2 blank states" severity note;

        -- Rotate each population through all input positions to catch index omissions.
        for count in 0 to 25 loop
            for rotation in 0 to 24 loop
                vote_bits := (others => '0');
                for index in 0 to 24 loop
                    if index < count then
                        vote_bits((index + rotation) mod 25) := '1';
                    end if;
                end loop;
                votes25 <= vote_bits;
                wait for 1 ns;
                if count >= 13 then
                    assert majority = '1'
                        report "Majority failure count=" & integer'image(count) & " rotation=" & integer'image(rotation)
                        severity failure;
                else
                    assert majority = '0'
                        report "Majority failure count=" & integer'image(count) & " rotation=" & integer'image(rotation)
                        severity failure;
                end if;
            end loop;
        end loop;
        report "PASS vote25: 650 cases (26 populations x25 rotations)" severity note;

        for value in 0 to 8191 loop
            remainder := value;
            population := 0;
            while remainder > 0 loop
                population := population + (remainder mod 2);
                remainder := remainder / 2;
            end loop;
            votes13 <= std_logic_vector(to_unsigned(value, 13));
            enabled <= '0';
            wait for 1 ns;
            assert count_segments = x"00"
                report "Disabled display failure input=" & integer'image(value) severity failure;
            enabled <= '1';
            wait for 1 ns;
            assert count_segments = count_masks(population)
                report "Count display failure input=" & integer'image(value) & " population=" & integer'image(population)
                severity failure;
        end loop;
        report "PASS vote13_display: 16384 cases (8192 inputs x2 enable states)" severity note;
        report "ALL TESTS PASSED: 19106 cases" severity note;
        wait;
    end process;
end architecture;
