#!/bin/bash

ROOTDIR="$(dirname "$(realpath "$0")")"
cd "$ROOTDIR"

# trap to kill all subprocesses
trap "pkill -P $$; exit" SIGINT SIGTERM

# commandline arguments
timeout="0"
grepQueries=".*"
vgrepQueries=".^"
if [ $# -eq 0 ]; then
    NcpusToUse="6"
    NrunsToAvg="2"
elif [ $# -eq 2 ]; then
    NcpusToUse="$1"
    NrunsToAvg="$2"
elif [ $# -eq 3 ]; then
    NcpusToUse="$1"
    NrunsToAvg="$2"
    timeout="$3"
elif [ $# -eq 4 ]; then
    NcpusToUse="$1"
    NrunsToAvg="$2"
    timeout="$3"
    grepQueries="$4"
elif [ $# -eq 5 ]; then
    NcpusToUse="$1"
    NrunsToAvg="$2"
    timeout="$3"
    grepQueries="$4"
    vgrepQueries="$5"
else
    echo "Usage: $0 use_n_CPU_cores num_runs_to_avg [timeout [grep_queries [inverted_grep_queries]]]"
    exit 1
fi


queries=$(cat makefile | grep ":" | sed "s|:||" | sed "s| |\n|g" | grep "$grepQueries" | grep -v "$vgrepQueries")
Nqueries=$(echo "$queries" | wc -l)
Ncpus=$(cat /proc/cpuinfo | grep "cpu cores" | head -n1 | sed "s|.*: ||")


# clean last outputs and prep folder for new outputs
rm -rf "./last_test_output/"
mkdir -p "./last_test_output/"

# print intro
echo "Running queries for the PCA pump specification:" | tee "./last_test_output/test_run.log"
echo "  using a pool of $NcpusToUse CPU cores (out of $Ncpus available) to run $Nqueries queries in parallel" | tee -a "./last_test_output/test_run.log"
echo | tee -a "./last_test_output/test_run.log"

# print progress bar and then jump cursor back to start
for i in $(seq 1 1 "$Nqueries"); do
    echo -e "$i\tIN PROGRESS"
done
echo -en "\033[${Nqueries}A"

run_queries()
{
    # run all queires in parallel using a pool of CPUs, and measure the total runtime
    # NOTE: shuffle the list of queries bc some batches of queries may take longer (e.g., to try and avoid one thread having to do all the slow queries)
    echo "$queries" | shuf | xargs -I CMD --max-procs=$NcpusToUse bash -c "./thread.sh $NrunsToAvg $timeout CMD"
}

{ time run_queries ; } 2> ./last_test_output/total_time.txt


# change memory measurements to GB from KB
sed -i "s|^  mem  \[K[Bb]\] \([0-9]\{1\}\)$|  mem  [GB] 0.00000\1|"             ./last_test_output/*.txt
sed -i "s|^  mem  \[K[Bb]\] \([0-9]\{2\}\)$|  mem  [GB] 0.0000\1|"              ./last_test_output/*.txt
sed -i "s|^  mem  \[K[Bb]\] \([0-9]\{3\}\)$|  mem  [GB] 0.000\1|"               ./last_test_output/*.txt
sed -i "s|^  mem  \[K[Bb]\] \([0-9]\{4\}\)$|  mem  [GB] 0.00\1|"                ./last_test_output/*.txt
sed -i "s|^  mem  \[K[Bb]\] \([0-9]\{5\}\)$|  mem  [GB] 0.0\1|"                 ./last_test_output/*.txt
sed -i "s|^  mem  \[K[Bb]\] \([0-9]\{6\}\)$|  mem  [GB] 0.\1|"                  ./last_test_output/*.txt
sed -i "s|^  mem  \[K[Bb]\] \([0-9][0-9]*\)\([0-9]\{6\}\)$|  mem  [GB] \1.\2|"  ./last_test_output/*.txt

# sort the results of queries
logSortedQueryResults=$(cat "./last_test_output/test_run.log" | tail -n+4 | LC_ALL=C.UTF-8 sort)
logHead=$(cat "./last_test_output/test_run.log" | head -n 3)
# rewrite the log file with the sorted query results
echo "$logHead" > "./last_test_output/test_run.log"
echo >> "./last_test_output/test_run.log"
echo "$logSortedQueryResults" >> "./last_test_output/test_run.log"

# append total time
echo | tee -a "./last_test_output/test_run.log"
cat "./last_test_output/total_time.txt" | tee -a "./last_test_output/test_run.log"
exit 0
