setup() {
	load 'test_helper/bats-assert/load'
	load 'test_helper/bats-support/load'
	DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
	PATH="$DIR/..:$PATH"

	source zshmarks-improved.plugin.zsh

	rm -rf ~/tempdir
	mkdir ~/tempdir
	cd ~/tempdir
}

teardown() {
	rm -rf ~/tempdir
}

@test "delete message" {
	bookmark tmp

	run deletemark tmp
	assert_output -p "Bookmark 'tmp' deleted"
}

@test "bookmark with same prefix" {
	bookmark tmpa

	run bookmark tmp
	assert_output -p "Bookmark 'tmp' saved"

	deletemark tmpa
	deletemark tmp
}

@test "output sorting/formatting" {
	bookmark tmpc
	bookmark tmpa
	bookmark tmpb

	output="$(showmarks)"
	good_output="$(showmarks | sort | column -t)"

	[ "$output" = "$good_output" ]
	
	deletemark tmpc
	deletemark tmpa
	deletemark tmpb
}