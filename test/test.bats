setup() {
	DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
	PATH="$DIR/..:$PATH"
	zshmarks-improved.plugin.zsh
}

@test "can run our script" {
	run 
}
