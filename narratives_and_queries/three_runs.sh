#!/bin/bash

#USRDIR="$(pwd)"
#ROOTDIR="$(dirname "$(realpath "$0")")"

if [ $# -eq 3 ]; then
    query_location=$1
    query_name=$2
    model=$3
else
    echo "Usage: $0 query_location query_name model_file"
    exit 1
fi

cd "$query_location"

# clear previous run just in case
rm -f $query_location/$query_name-additions-*

fact_additions=""
for RunN in 1 2; do
    triggered_events_to_facts=$(cat $query_location/$query_name-multirun-$RunN.pl | grep "%#TO FACT HAPPENS# " | sed "s|.*%#TO FACT HAPPENS# ||" | sed "s| *$||")
    echo
    echo "#### run $RunN ###########################################################"
    echo "scasp -s0 --dcc $model $query_location/$query_name-multirun-$RunN.pl $fact_additions"
    RunN_output=$(scasp -s0 --dcc $model $query_location/$query_name-multirun-$RunN.pl $fact_additions 2>&1)

    facts_to_add=""
    for triggered_event in $triggered_events_to_facts; do
        fact=$(echo "$RunN_output" | sed "s|,  |\n|g" | grep "$triggered_event" | sed "s|$triggered_event|${triggered_event}_EFFECT|" | sed "s|.*happens|or_happens|" | sed "s|) *$|).|" )
        facts_to_add=$(echo "$facts_to_add$fact; ")
    done
    facts_to_add=$(echo "$facts_to_add" | sed "s|; |\n|g")
    echo "$RunN_output"

    echo
    echo "#### run $RunN new facts #################################################"
    touch $query_location/$query_name-additions-$RunN.tmp
    echo "$facts_to_add" | tee $query_location/$query_name-additions-$RunN.tmp
    fact_additions="${fact_additions}$query_location/$query_name-additions-$RunN.tmp "
done

# last (third) run
echo
echo "#### run 3 ##########################################################"
echo "scasp -s0 --dcc $model $query_location/$query_name-multirun-3.pl $fact_additions"
scasp -s0 --dcc $model $query_location/$query_name-multirun-3.pl $fact_additions

echo
rm -f $query_location/$query_name-additions-*