#!/bin/bash

PATH=.:$PATH

prefix=/tmp/tracking-test
original=$prefix/orginal
clone=$prefix/clone
total_tests=0
total_failures=0
ans=
exp=

setup() {
    mkdir -vp $original
    cd $original
    git init
    git commit --allow-empty -m 'one'
    git commit --allow-empty -m 'two'
    git checkout -b branch HEAD^
    git commit --allow-empty -m 'three'
    cd ..
    git clone $original $clone
    cd $clone
}

tear_down(){
    rm -rf $prefix
}

run_test() {
    setup
    "@1"
    tear_down
}

assert_equal(){
    if [[ $ans == $exp ]]; then
        echo -n .
        total_tests=$( expr $total_tests + 1)
    else
        echo "Test Failed:"
        echo -e $ans
        echo "Not equal too:"
        echo -e $exp
        total_failures=$( expr $total_failures + 1)
    fi
}

# test stop tracking
    setup
    ans=$( git tracking stop )
    exp="Branch 'branch' is no longer tracking 'origin/branch'."
    assert_equal
    ans=$( git tracking stop)
    exp="error: Your branch 'branch' isn't tracking anything."
    assert_equal
    tear_down

# test start tracking
    setup
    git tracking stop
    ans=$( git tracking start origin/branch )
    exp="Branch 'branch' setup to track remote branch 'branch' from 'origin'."
    assert_equal
    ans=$( git tracking start origin/branch | head -1)
    exp="error: Your branch 'branch' is already tracking 'origin/branch'"
    assert_equal
    ans=$( git tracking start -f origin/branch | head -2 | tail -n 1)
    exp="Branch 'branch' setup to track remote branch 'branch' from 'origin'."
    assert_equal
    git tracking stop
    ans=$( git tracking start foo | head -1)
    exp="error: Remote tracking branch was not specified as <remote>/<branch>."
    assert_equal
    ans=$(git tracking start ori/foo)
    exp="error: Can not start tracking, remote 'ori' does not exist!"
    assert_equal
    ans=$(git tracking start origin/foo)
    exp="error: Can not start tracking, remote 'origin' does not appear to have a branch 'foo'."
    assert_equal
    tear_down

echo
echo "Ran $total_tests tests, with $total_failures failure(s)."

