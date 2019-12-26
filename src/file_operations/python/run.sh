#!/bin/bash
source ~/.bash_profile
bash _helper_scripts/venv.sh

echo "############### TESTS #####################"
echo "Running tests for the original solution."
python original/file_operations.py tests/data/small.txt he

echo "Running tests for the alternative solution."
python alternative/file_operations.py tests/data/small.txt he