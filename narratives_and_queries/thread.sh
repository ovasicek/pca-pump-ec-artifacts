#!/bin/bash

ROOTDIR="$(dirname "$(realpath "$0")")"
cd "$ROOTDIR"

# trap to kill all subprocesses
trap "pkill -P $$; exit" SIGINT SIGTERM

# commandline arguments
if [ $# -eq 3 ]; then
    N_AVG="$1"  # how many times to run the query, to average the runtime
    timeout="$2"
    queryWdir="$3"  # query to run 
else
    echo "Usage: $0 num_runs_to_avg query_to_run timeout"
    exit 1
fi

query=$(echo $queryWdir | sed "s|multi_run_alarms/||")    # can contain a directory prefix "multi_run_alarms/"

totalRuntime=0
totalMemory=0
for i in $(seq 1 $N_AVG)
do
    { /usr/bin/time -f "\n  real [s]  %e\n  user [s]  %U\n  sys  [s]  %S\n  mem  [KB] %M" timeout --foreground $timeout make $query ; } 1> ./last_test_output/$query.txt 2>&1

    runtime=$( cat ./last_test_output/"$query".txt | grep "real \[s\]" | sed "s|  real \[s\]||")
    totalRuntime=$(awk "BEGIN{ print $runtime + $totalRuntime }")
    memory=$( cat ./last_test_output/"$query".txt | grep "[ \t]*mem  \[KB\][ \t]*" | sed "s|[ \t]*mem  \[KB\][ \t]*||")
    totalMemory=$(awk "BEGIN{ print $memory + $totalMemory }")
done

avgRuntime=$(awk -v OFMT="%.2f" "BEGIN{ print $totalRuntime / $N_AVG }")
avgRuntimeMins=$(awk -v OFMT="%.2f" "BEGIN{ print $avgRuntime / 60 }")
avgMemory=$(awk -v OFMT="%.2f" "BEGIN{ print $totalMemory / $N_AVG / 1000 }")   # and change from KB to MB
sed -i "s|^  real \[s\]  [0-9\.]*$|  real [m]  $avgRuntimeMins (avg of $N_AVG runs)\n  real [s]  $avgRuntime (avg of $N_AVG runs)|" ./last_test_output/$query.txt
sed -i "s|^  mem  \[KB\] [0-9\.]*$|  mem  [MB] $avgMemory (avg of $N_AVG runs)|" ./last_test_output/$query.txt

# check output and print the result
Nmodels=$( cat ./last_test_output/"$query".txt | grep -c "ANSWER" )

printf "%-40s  %+4s models  %+10ss  %+10sMB\n" "$query" "${Nmodels}" "${avgRuntime}" "${avgMemory}" | tee -a "./last_test_output/test_run.log"