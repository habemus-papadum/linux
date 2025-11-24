set pagination off
file vmlinux
target remote :1234

b sys_demo_strlen
commands
	silent
	printf "hit sys_demo_strlen(user_str=%#lx, maxlen=%ld)\n", $rdi, $rsi
	c
end

continue
