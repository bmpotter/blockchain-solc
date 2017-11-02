#!/bin/bash

git ls-remote --tags https://github.com/ethereum/solidity.git | tail -1 | perl -p -e 's/.*?([\.\d]+)$/$1/'

