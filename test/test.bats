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

@test "bookmark_1" {
	bookmark
	deletemark tempdir
}

@test "bookmark_2" {
	bookmark tmp
	deletemark tmp
}

@test "bookmark_3" {
	cd /
	bookmark tmp
	deletemark tmp
}

@test "bookmark_4" {
	bookmark tmp
	run bookmark tmp
	assert_output -p "Bookmark already existed"
	deletemark tmp
}

@test "jump_1" {
	run jump fuck
	assert_output -p "Invalid name"
}

@test "jump_2" {
	bookmark tmp
	folder=$(pwd)
	cd ~
	jump tmp
	new_folder=$(pwd)
	[ "$folder" = "$new_folder" ]
	deletemark tmp
}

@test "showmarks_1" {
	showmarks
}

@test "deletemark_1" {
	run deletemark
	assert_output -p "Please provide"
}

@test "deletemark_2" {
	run deletemark fuck
	assert_output -p "not found"
}

@test "deletemark_3" {
	bookmark tmp
	deletemark tmp
}
