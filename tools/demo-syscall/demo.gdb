set pagination off
set breakpoint pending on
file vmlinux
target remote :1234

# 64-bit user processes hit this symbol; compat would hit __ia32_sys_demo_strlen.
b __x64_sys_demo_strlen
commands
	silent
	printf "hit __x64_sys_demo_strlen(user_str=%#lx, maxlen=%ld)\n", $rdi, $rsi
	c
end

# Allow this to fail quietly if you are not running 32-bit compat tasks.
b __ia32_sys_demo_strlen
commands
	silent
	printf "hit __ia32_sys_demo_strlen(user_str=%#lx, maxlen=%ld)\n", $rdi, $rsi
	c
end

continue
