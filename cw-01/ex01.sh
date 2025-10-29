#!/bin/bash
# Aleksander Pugowski
# set -x -e 

function isNumber() { # nie mój regex - https://unix.stackexchange.com/questions/151654/checking-if-an-input-number-is-an-integer
 if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        return 1
fi
    return 0
}

function areInputsTooBig(){
    local largestMultiplyResult=$(($1*$2))
    local largestMultiplyResultLength=${#largestMultiplyResult}
    if [[ $largestMultiplyResultLength -gt 4 ]]; then
        return 0
    fi
    return 1;
}

# Walidacja
if [[ $# -eq 1 ]]; then
    startNumber=1
    endNumber=$1
elif [[ $# -eq 2 ]]; then
    startNumber=$1
    endNumber=$2
else 
    echo "Usage: $0 <num1> [num2]"
    exit 1
fi

if ! isNumber "$startNumber" || ! isNumber $endNumber || [[ $endNumber -lt $startNumber ]] || [[ $startNumber -lt 0 ]]; then
    exit 1
fi 

if areInputsTooBig $startNumber $endNumber; then
    exit 1
fi

# Wlasciwy task
function formatAndPrint(){
    local number=$1
    local len=${#number}
    if [[ $len -eq 0 ]]; then
        echo -n "    "
    elif [[ $len -eq 1 ]]; then
        echo -n "   $1"
    elif [[ $len -eq 2 ]]; then
        echo -n "  $1"
    elif [[ $len -eq 3 ]]; then
        echo -n " $1"
    elif [[ $len -eq 4 ]]; then
        echo -n "$1"
    fi
}

formatAndPrint ""
for (( i=$startNumber; i<=$endNumber; i++ )); do
    formatAndPrint "$i" 
done
echo ""

for (( i=$startNumber; i<=$endNumber; i++ )); do 
    formatAndPrint $i
    for (( j=$startNumber; j<=$endNumber; j++ )); do
            formatAndPrint "$((i*j))"
    done
    echo ""
done

