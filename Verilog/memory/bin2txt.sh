hexdump -v -e '16/1 "%02x " "\n"' code.bin | tr '\n' ' ' > spi.txt

