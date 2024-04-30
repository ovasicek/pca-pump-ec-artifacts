#!/bin/bash

USRDIR="$(pwd)"
ROOTDIR="$(dirname "$(realpath "$0")")"

DEPTH_LIMIT=10

# commandline arguments
MODEL="$1"
ABDUCIBLE_PRED_W2PARAMS="$2"
INCLUDE_FILES="$3"
QUERY="$4"
if [ $# -eq 4 ]; then
    DEBUG=false
    NO_RUN=false
elif [ $# -eq 5 ] && [ $5 == "-g" ]; then
    DEBUG=true
    NO_RUN=false
elif [ $# -eq 5 ] && [ $5 == "-r" ]; then
    DEBUG=false
    NO_RUN=true
elif [ $# -eq 6 ] && [ $5 == "-g" ] && [ $6 == "-r" ]; then
    DEBUG=true
    NO_RUN=true
elif [ $# -eq 6 ] && [ $5 == "-r" ] && [ $6 == "-g" ]; then
    DEBUG=true
    NO_RUN=true
else
    echo "Usage: $0 MODEL ABDUCIBLE INCLUDE_FILES QUERY [-g][-r]"
    echo "    MODEL         -- which version of the model to use"
    echo "                     (e.g., model-original.pl or model-fixed.pl)"
    echo "    ABDUCIBLE     -- predicate with 2 parameters to be abduced"
    echo "                     and then used as a new fact"
    echo "    INCLUDE_FILES -- other .pl files to include when executing queries"
    echo "    QUERY         -- file with the narrative and query"
    echo "    -g            -- enable debug outputs"
    echo "    -r            -- dont rerun scasp (needs outputs from"
    echo "                     a previous run of this script)"
    echo
    exit 2
fi

MODELNAME=$(echo "$MODEL" | sed "s|^.*[\\/]||")  # strip path to get filename
LOGFILE=./abduction_output/output-$MODELNAME.log 2>&1
SCASP_ARGS=""
if $DEBUG; then SCASP_ARGS="--tree"; fi


# prep the output directory
mkdir ./abduction_output 2>/dev/null

# mark start of script in the output
echo -n "DATE: " > $LOGFILE; date >> $LOGFILE

# clear certain files from the previous run just in case
rm -f ./abduction_output/2D/tmp-$MODELNAME-executedBefore.tmp ./abduction_output/2D/output-$MODELNAME-consistentAbductions.log ./abduction_output/2D/output-$MODELNAME-consistentAbductionsSummary.log
rm -f ./abduction_output/1D/tmp-$MODELNAME-executedBefore.tmp ./abduction_output/1D/output-$MODELNAME-consistentAbductions.log ./abduction_output/1D/output-$MODELNAME-consistentAbductionsSummary.log

# copy over the query file for reference when looking at the outputs later
cp "$QUERY" ./abduction_output/query.pl

# statistics variables
CUR_PHASE_NUMBER_OF_MODELS=0
PHASE_2D_NUMBER_OF_MODELS=0
PHASE_1D_NUMBER_OF_MODELS=0

CUR_PHASE_NUMBER_OF_SPURIOUS=0
PHASE_2D_NUMBER_OF_SPURIOUS=0
PHASE_1D_NUMBER_OF_SPURIOUS=0

CUR_PHASE_NUMBER_OF_CONSISTENT=0
PHASE_2D_NUMBER_OF_CONSISTENT=0
PHASE_1D_NUMBER_OF_CONSISTENT=0

PHASE_2D_NUMBER_OF_RESULTS=0
PHASE_1D_NUMBER_OF_RESULTS=0

CUR_PHASE_NUMBER_OF_DEPTH=0
PHASE_2D_NUMBER_OF_DEPTH=0
PHASE_1D_NUMBER_OF_DEPTH=0

CUR_PHASE_NUMBER_OF_EXECUTIONS=0
PHASE_2D_NUMBER_OF_EXECUTIONS=0
PHASE_1D_NUMBER_OF_EXECUTIONS=0

CUR_PHASE_NUMBER_OF_DUPLICATES=0
PHASE_2D_NUMBER_OF_DUPLICATES=0
PHASE_1D_NUMBER_OF_DUPLICATES=0

CUR_PHASE_NUMBER_OF_REFINED=0
PHASE_2D_NUMBER_OF_REFINED=0
PHASE_1D_NUMBER_OF_REFINED=0


# recursive function used to force&check consistent abduction values
#
# General recursive algorithm
# - look at all models produced as results of the query $6 which are located in the output file $3 of that query run
# - for each model
#   - extract all the abduced values of $ABDUCIBLE_PRED_W2PARAMS from that model (predicate with two parameters, each
#     parameter will likely have an interval of values as a result of abduction)
#   - if all the abduced values/intervals across the whole model are the exact same, then the model is as consistent
#     as possible in the current phase (phases are 2D and 1D ~~> meaning how many parameters are being abduced)
#     - save the abduced values as a result and dont further process this model
#   - merge all the abduced values together (intersection of intervals)
#     - currently done by simply taking all the constraints and putting them in one rule (so all constraints apply)
#   - check if the merged interval has already been executed before or not (using a cache of previously executed)
#     - if yes then stop further processing this model
#   - check how deep in the resursing we are currently, stop if the $DEPTH_LIMIT was reached
#   - execute the query $6 again while limiting abduction to the merged interval
#   - if there is no model, then this merged interval is not valid, stop further processing this model
#   - if there is a model(s), then recursively run this function and pass it the output of the query which was just
#     executed --> recursively repeats the same process to make the abduction interval smaller and smaller (intersections)
anotherRun() {
    local runN="$1"
    local modelNumberPrefix="$2"
    local lastRunOutputFile="$3"
    local indent="$4"
    local outputDir="$5"
    local queryToRun="$6"

    local lastRunN=$((runN-1))
    local nextRunN=$((runN+1))

    # find each model in the output (each model is a single line)
    # result will be one model per line
    local oneModelPerLine=$(cat "$lastRunOutputFile" | grep -A1 MODEL: | grep -v "^--$\|^MODEL:$" | sed "s| *||g")
    #if $DEBUG; then echo "Original abduction models:" ; echo "$oneModelPerLine" | sed "s|^|    |"; fi

    # extract all occurences of the abducible fact from each of the models
    # result will be multiple abducible facts per line (one line for each model) separated by ';'
    local abducedFactsForModelPerLine=$(   
    for oneModel in $oneModelPerLine; do
        local abducedFacts=$(echo "$oneModel" | sed "s|$ABDUCIBLE_PRED_W2PARAMS|\n$ABDUCIBLE_PRED_W2PARAMS|g" | grep "$ABDUCIBLE_PRED_W2PARAMS" | sed "s|^.*\($ABDUCIBLE_PRED_W2PARAMS([^)]*)\).*|\1|" | sed "s| *||g")
        echo $abducedFacts
    done
    )
    local abducedFactsForModelPerLine=$(echo "$abducedFactsForModelPerLine" | sed "s| |;|g")
    
    # count models
    local numOfModels=$(echo "$abducedFactsForModelPerLine" | wc -l )
    echo "${indent}#$modelNumberPrefix# Number of models:$numOfModels" >> $LOGFILE
    CUR_PHASE_NUMBER_OF_MODELS=$((CUR_PHASE_NUMBER_OF_MODELS+numOfModels))

    # parse variables
    local parsedAbducedVarsForModelPerLine=$(   
    for abducedFactsFromOneModel in $abducedFactsForModelPerLine; do # for each line (for each model)
        local parsedAbducedVarsForOneModel=""
        for oneAbductionFactFromOneModel in $(echo "$abducedFactsFromOneModel" | sed "s|;|\n|g"); do # split the line on semicolons, then for each line (for each abduced fact/value)
            local matchLeftVar=""
            local writeLeftVar=""
            local matchRightVar=""
            local writeRightVar=""
            if [ $(echo "$oneAbductionFactFromOneModel" | grep -c "},") -ge 1 ]; then   # first parameter is an interval
                matchLeftVar=".*(.*{\(.*\)}"
                writeLeftVar="\1"
            else    # first parameter is a constant
                matchLeftVar=".*(\(.*\)"
                writeLeftVar="X1.=.\1"
            fi
            if [ $(echo "$oneAbductionFactFromOneModel" | grep -c "})") -ge 1 ]; then   # second parameter is an interval
                matchRightVar=".*{\(.*\)}.*).*"
                writeRightVar="\2"
            else    # second parameter is a constant
                matchRightVar="\(.*\)).*"
                writeRightVar="X2.=.\2"
            fi

            local parsedVars=$(echo "$oneAbductionFactFromOneModel" | sed "s|$matchLeftVar,$matchRightVar|$writeLeftVar,$writeRightVar|")
            parsedAbducedVarsForOneModel="$parsedAbducedVarsForOneModel;$parsedVars"
        done
        echo "$parsedAbducedVarsForOneModel" | sed "s|^;||"
    done
    )

    # rename variables in all facts to X1 and X2
    local renamedAbducedFactsForModelPerLine=$(   
    for abducedFactsFromOneModel in $parsedAbducedVarsForModelPerLine; do # for each line (for each model)
        local renamedAbductionFactsForOneModel=""
        for oneAbductionFactFromOneModel in $(echo "$abducedFactsFromOneModel" | sed "s|;|\n|g"); do # split the line on semicolons, then for each line (for each abduced fact/value)
            # get all variable names used in the fact
            local factVariables=$(echo "$oneAbductionFactFromOneModel" | sed "s|\(Var[0-9][0-9]*\)|\1\n|g" | grep "Var[0-9][0-9]*" | sed "s|.*\(Var[0-9][0-9]*\)|\1|g" | LC_ALL=C.UTF-8 sort | uniq)
            local i=1
            # rename each variable to X1, X2, ... XN
            for var in $factVariables; do
                oneAbductionFactFromOneModel=$(echo -n "$oneAbductionFactFromOneModel" | sed "s|$var|X$i|g")
                i=$((i+1))
            done
            renamedAbductionFactsForOneModel="$renamedAbductionFactsForOneModel;$oneAbductionFactFromOneModel"
        done
        echo "$renamedAbductionFactsForOneModel" | sed "s|^;||"
    done
    )

    # for each model, remove duplicate abduced values (exact same abduced predicates)
    # if there ends up being only one unique predicate, then there is no need to run this model again (already used the same values everywhere)
    local i=0
    local numbered_needMoreRunsAbducedFactsForModelPerLine=""
    for abducedFactsForOneModel in $renamedAbducedFactsForModelPerLine; do
        i=$((i+1))
        local modelNumber="$modelNumberPrefix$i"
        abducedFactsForOneModel=$(echo "$abducedFactsForOneModel" | sed "s|;|\n|g")
        local uniqueAbducedFactsForOneModel=$(echo "$abducedFactsForOneModel" | LC_ALL=C.UTF-8 sort | uniq)
        local numOfUniqueFacts=$(echo "$uniqueAbducedFactsForOneModel" | wc -l)
        if [ "$numOfUniqueFacts" -eq 1 ]; then
            echo "${indent}#$modelNumberPrefix# Model $modelNumber is already consistent (see Model $i in \"$lastRunOutputFile\")" >> $LOGFILE
            echo "abduction: $uniqueAbducedFactsForOneModel; model number: $modelNumber; from: $lastRunOutputFile" >> $outputDir/output-$MODELNAME-consistentAbductions.log
            echo "$uniqueAbducedFactsForOneModel" >> $outputDir/output-$MODELNAME-consistentAbductionsSummary.log
            CUR_PHASE_NUMBER_OF_CONSISTENT=$((CUR_PHASE_NUMBER_OF_CONSISTENT+1))
        else
            #if $DEBUG; then echo "Model $modelNumberPrefix$i needs more runs"; fi
            local uniqueAbducedFactsForOneModel_asOneLine=$(echo $uniqueAbducedFactsForOneModel | sed "s| |;|g")
            numbered_needMoreRunsAbducedFactsForModelPerLine=$(echo -e "$numbered_needMoreRunsAbducedFactsForModelPerLine\n$modelNumber:$uniqueAbducedFactsForOneModel_asOneLine" | grep -v "^$")
        fi
    done


    # for each model, merge all abduced intervals into one (intersection) using scasp as a constraint solver
    # if intersection is not possible, then the model is spurious/invalid
    local numbered_needMoreRunsOneMergedFactModelPerLine=""
    for abducedFactsForOneModel in $numbered_needMoreRunsAbducedFactsForModelPerLine; do
        local modelNumber=$(echo "$abducedFactsForOneModel" | sed "s|:.*$||")
        abducedFactsForOneModel=$(echo "$abducedFactsForOneModel" | sed "s|^[0-9D\.]*:||")
        local deduplicatedAbducedFactsForOneModel=$(echo "$abducedFactsForOneModel" | sed "s|[;,]|\n|g" | LC_ALL=C.UTF-8 sort | uniq)
        local asOneLine=$(echo $deduplicatedAbducedFactsForOneModel | sed "s| |,|g")
        
        if $DEBUG; then echo "${indent}#$modelNumberPrefix# MODEL $modelNumber" >> $LOGFILE; fi
        if $DEBUG; then echo "$abducedFactsForOneModel" | sed "s|;|\n|g" | sed "s|^|    abduced: |" | sed "s|^|${indent}#$modelNumberPrefix#|" >> $LOGFILE; fi
        
        # run scasp as a constraint solver to do the intersection of all intervals
        echo "?- $asOneLine." > $outputDir/tmpConstraintSolvnigQuery-$MODELNAME.tmp
        local constraintOut=$(scasp $outputDir/tmpConstraintSolvnigQuery-$MODELNAME.tmp -s1)
        if [ $(echo "$constraintOut" | grep -c "no models") -ge 1 ]; then
            echo "${indent}#$modelNumberPrefix# Model $modelNumber is spurious (failed to intersect abduction intervals)" >> $LOGFILE
            CUR_PHASE_NUMBER_OF_SPURIOUS=$((CUR_PHASE_NUMBER_OF_SPURIOUS+1))
        else
            local constraintSolved=$(echo "$constraintOut" | grep -A2 "BINDINGS:" | grep -v "BINDINGS:"| sed "s| ||g")
            constraintSolved=$(echo $constraintSolved | sed "s| |,|g")

            numbered_needMoreRunsOneMergedFactModelPerLine=$(echo "$(echo "$numbered_needMoreRunsOneMergedFactModelPerLine"; echo "$constraintSolved"| sed "s|^|$modelNumber:|")" | grep -v "^$")
            if $DEBUG; then echo "${indent}#$modelNumberPrefix#    merged:  $constraintSolved" >> $LOGFILE; fi
        fi
    done
    echo >> $LOGFILE

    # for each model, check if it has already been executed before (e.g., in a diff branch)
    # if yes then do not execute again
    # if not then add it to the list of already executed models and execute it later 
    local numbered_notCheckedBeforeAbducedFactsForModelPerLine=""
    for abducedFactsForOneModel in $numbered_needMoreRunsOneMergedFactModelPerLine; do
        local modelNumber=$(echo "$abducedFactsForOneModel" | sed "s|:.*$||")
        abducedFactsForOneModel=$(echo "$abducedFactsForOneModel" | sed "s|^[0-9D\.]*:||")

        local executedBeforeAs=$(cat "$outputDir/tmp-$MODELNAME-executedBefore.tmp" | grep "^[0-9D\.]*:$abducedFactsForOneModel$" | sed "s|^\([0-9D\.]*\):.*$|\1|")
        if [ $(echo "$executedBeforeAs" | grep -vc "^$") -ne 0 ]; then
            echo "${indent}#$modelNumberPrefix# Model $modelNumber has already been executed before (or is about to be ex.) as Model $executedBeforeAs" >> $LOGFILE
            CUR_PHASE_NUMBER_OF_DUPLICATES=$((CUR_PHASE_NUMBER_OF_DUPLICATES+1))
        else
            echo -e "$modelNumber:$abducedFactsForOneModel" >> "$outputDir/tmp-$MODELNAME-executedBefore.tmp"
            numbered_notCheckedBeforeAbducedFactsForModelPerLine=$(echo -e "$numbered_notCheckedBeforeAbducedFactsForModelPerLine\n$modelNumber:$abducedFactsForOneModel" | grep -v "^$")
        fi 
    done
    echo >> $LOGFILE

    echo "${indent}#$modelNumberPrefix# Initial models (renamed & internaly unique & globaly unique):" >> $LOGFILE
    echo "$numbered_notCheckedBeforeAbducedFactsForModelPerLine" | sed "s|$ABDUCIBLE_PRED_W2PARAMS||g" | sed "s|^|${indent}#$modelNumberPrefix# |" >> $LOGFILE

    # for each model, merge all the abduced values into a single constraint (intersect all intervals), remove the original abduction,
    # add new abduction using the new constraint, then run again
    for abducedFactsForOneModel in $numbered_notCheckedBeforeAbducedFactsForModelPerLine; do
        local modelNumber=$(echo "$abducedFactsForOneModel" | sed "s|:.*$||")
        abducedFactsForOneModel=$(echo "$abducedFactsForOneModel" | sed "s|^[0-9D\.]*:||")

        # create the new abducible rule by combining all the above values into a single rule
        local newAbducibleFact=$(echo "$ABDUCIBLE_PRED_W2PARAMS(X1,X2):-new_abduction(X1,X2),$abducedFactsForOneModel.")

        # second run with the new constrained abduction to confirm if the model is feasible (not spurious due to abducing multiple diff values in one model)
        echo "#show $ABDUCIBLE_PRED_W2PARAMS/2." > $outputDir/tmp-$MODELNAME-addition.tmp
        echo "#show new_abduction/2." >> $outputDir/tmp-$MODELNAME-addition.tmp
        echo "#abducible new_abduction(X, Y)." >> $outputDir/tmp-$MODELNAME-addition.tmp
        echo "$newAbducibleFact" >> $outputDir/tmp-$MODELNAME-addition.tmp
        if ! $NO_RUN; then
            { /usr/bin/time -f "\n  real      %E\n  real [s]  %e\n  user [s]  %U\n  sys  [s]  %S\n  mem  [KB] %M\n  avgm [KB] %K" scasp -s0 --dcc $SCASP_ARGS "$MODEL" $INCLUDE_FILES $outputDir/tmp-$MODELNAME-addition.tmp $queryToRun ; } > $outputDir/runs/output-$MODELNAME-run$runN-model$modelNumber.log 2>&1
            CUR_PHASE_NUMBER_OF_EXECUTIONS=$((CUR_PHASE_NUMBER_OF_EXECUTIONS+1))
            echo -n "${indent}#$modelNumberPrefix# execution time of run$runN-model$modelNumber: " >> $LOGFILE
            grep "  real      " $outputDir/runs/output-$MODELNAME-run$runN-model$modelNumber.log | sed "s|  real      ||" >> $LOGFILE
        fi
        local outRunN=$(cat $outputDir/runs/output-$MODELNAME-run$runN-model$modelNumber.log)
        
        # see if there still is a model or not
        if [ $(echo "$outRunN" | grep -c "no models") -ge 1 ]; then
            echo "${indent}#$modelNumberPrefix# Model $modelNumber is spurious (no models for new abduction interval)" >> $LOGFILE
            CUR_PHASE_NUMBER_OF_SPURIOUS=$((CUR_PHASE_NUMBER_OF_SPURIOUS+1))
            #rm $outputDir/runs/output-$MODELNAME-run$runN-model$modelNumber.log
        else
            #echo "${indent}#$modelNumberPrefix# Model $modelNumber might be valid (see $outputDir/runs/output-$MODELNAME-run$runN-model$modelNumber.log)"
            if [ "$runN" -eq "$DEPTH_LIMIT" ]; then
                echo "${indent}#$modelNumberPrefix# Depth limit ($DEPTH_LIMIT) reached on refinement of model $modelNumber" >> $LOGFILE
                CUR_PHASE_NUMBER_OF_DEPTH=$((CUR_PHASE_NUMBER_OF_DEPTH+1))
            else
                echo "${indent}#$modelNumberPrefix# Further refining model $modelNumber" >> $LOGFILE
                CUR_PHASE_NUMBER_OF_REFINED=$((CUR_PHASE_NUMBER_OF_REFINED+1))
                anotherRun $nextRunN "$modelNumber." "$outputDir/runs/output-$MODELNAME-run$runN-model$modelNumber.log" "$indent    " "$outputDir" "$queryToRun"
            fi
            
        fi

        if $DEBUG; then echo >> $LOGFILE; echo >> $LOGFILE; fi
    done
}

clearStatCounters() {
    CUR_PHASE_NUMBER_OF_MODELS=0
    CUR_PHASE_NUMBER_OF_CONSISTENT=0
    CUR_PHASE_NUMBER_OF_SPURIOUS=0
    CUR_PHASE_NUMBER_OF_DEPTH=0
    CUR_PHASE_NUMBER_OF_EXECUTIONS=0
    CUR_PHASE_NUMBER_OF_DUPLICATES=0
    CUR_PHASE_NUMBER_OF_REFINED=0
}

printStatCounters() {
    NUMBER_OF_MODELS=$1
    NUMBER_OF_SPURIOUS=$2
    NUMBER_OF_CONSISTENT=$3
    NUMBER_OF_DEPTH=$4
    NUMBER_OF_EXECUTIONS=$5
    NUMBER_OF_DUPLICATES=$6
    NUMBER_OF_RESULTS=$7
    NUMBER_OF_REFINED=$8

    echo "  N models" >> $LOGFILE
    echo "      total:        $NUMBER_OF_MODELS" >> $LOGFILE
    echo "      refined:      $NUMBER_OF_EXECUTIONS" >> $LOGFILE
    echo "      duplicates:   $NUMBER_OF_DUPLICATES" >> $LOGFILE
    echo "      spurions:     $NUMBER_OF_SPURIOUS" >> $LOGFILE
    echo "      consistent:   $NUMBER_OF_CONSISTENT" >> $LOGFILE
    echo "  depth limit" >> $LOGFILE
    echo "      set to:       $DEPTH_LIMIT" >> $LOGFILE
    echo "      N reached:    $NUMBER_OF_DEPTH" >> $LOGFILE
    echo "  N results:    $NUMBER_OF_RESULTS" >> $LOGFILE
    echo >> $LOGFILE
}

########################################################################################################################
echo -e "\n\n##########################################################################" >> $LOGFILE
echo "  2D abduction phase" >> $LOGFILE
echo -e "##########################################################################\n" >> $LOGFILE
########################################################################################################################

# prep the output directory
mkdir ./abduction_output/2D 2>/dev/null
mkdir ./abduction_output/2D/runs 2>/dev/null
touch ./abduction_output/2D/tmp-$MODELNAME-executedBefore.tmp ./abduction_output/2D/output-$MODELNAME-consistentAbductions.log ./abduction_output/2D/output-$MODELNAME-consistentAbductionsSummary.log

# clear stat counters
clearStatCounters

# first run with 2D abduction
echo "#show $ABDUCIBLE_PRED_W2PARAMS/2." > ./abduction_output/2D/tmp-$MODELNAME-addition.tmp
echo "#abducible $ABDUCIBLE_PRED_W2PARAMS(X,Y)." >> ./abduction_output/2D/tmp-$MODELNAME-addition.tmp
if ! $NO_RUN; then
    { /usr/bin/time -f "\n  real      %E\n  real [s]  %e\n  user [s]  %U\n  sys  [s]  %S\n  mem  [KB] %M\n  avgm [KB] %K" scasp -s0 --dcc $SCASP_ARGS "$MODEL" $INCLUDE_FILES ./abduction_output/2D/tmp-$MODELNAME-addition.tmp "$QUERY" ; } > ./abduction_output/2D/runs/output-$MODELNAME-run1-model2D.log 2>&1
    CUR_PHASE_NUMBER_OF_EXECUTIONS=$((CUR_PHASE_NUMBER_OF_EXECUTIONS+1))
    echo -n "## execution time of run1-model2D: " >> $LOGFILE
    grep "  real      " ./abduction_output/2D/runs/output-$MODELNAME-run1-model2D.log | sed "s|  real      ||" >> $LOGFILE
fi

# check if no models in the very first query
if [ $(cat "./abduction_output/2D/runs/output-$MODELNAME-run1-model2D.log" | grep -c "no models") -ge 1 ]; then
    echo "The very first query has no models" >> $LOGFILE
    exit
fi

# start the 2D recursive runs
anotherRun 2 "2D." ./abduction_output/2D/runs/output-$MODELNAME-run1-model2D.log "" "./abduction_output/2D" "$QUERY"

# process output files at the end
tmp=$(cat "./abduction_output/2D/output-$MODELNAME-consistentAbductionsSummary.log" | LC_ALL=C.UTF-8 sort | uniq -c | LC_ALL=C.UTF-8 sort -nr | sed "s|\([0-9]\) |\1;|" | sed "s| *||" )
echo "$tmp" > "./abduction_output/2D/output-$MODELNAME-consistentAbductionsSummary.log"

# copy stat counters
PHASE_2D_NUMBER_OF_MODELS=$CUR_PHASE_NUMBER_OF_MODELS
PHASE_2D_NUMBER_OF_SPURIOUS=$CUR_PHASE_NUMBER_OF_SPURIOUS
PHASE_2D_NUMBER_OF_CONSISTENT=$CUR_PHASE_NUMBER_OF_CONSISTENT
PHASE_2D_NUMBER_OF_DEPTH=$CUR_PHASE_NUMBER_OF_DEPTH
PHASE_2D_NUMBER_OF_EXECUTIONS=$CUR_PHASE_NUMBER_OF_EXECUTIONS
PHASE_2D_NUMBER_OF_DUPLICATES=$CUR_PHASE_NUMBER_OF_DUPLICATES
PHASE_2D_NUMBER_OF_REFINED=$CUR_PHASE_NUMBER_OF_REFINED
PHASE_2D_NUMBER_OF_RESULTS=$(cat "./abduction_output/2D/output-$MODELNAME-consistentAbductionsSummary.log" | grep -v "^$" | wc -l)

echo >> $LOGFILE
echo "2D phase stats" >> $LOGFILE
printStatCounters "$PHASE_2D_NUMBER_OF_MODELS" "$PHASE_2D_NUMBER_OF_SPURIOUS" "$PHASE_2D_NUMBER_OF_CONSISTENT" "$PHASE_2D_NUMBER_OF_DEPTH" "$PHASE_2D_NUMBER_OF_EXECUTIONS" "$PHASE_2D_NUMBER_OF_DUPLICATES" "$PHASE_2D_NUMBER_OF_RESULTS"

# mark end of the first part of the script in the output
echo -n "DATE: " >> $LOGFILE; date >> $LOGFILE


########################################################################################################################
echo -e "\n\n##########################################################################" >> $LOGFILE
echo "  1D abduction phase" >> $LOGFILE
echo -e "##########################################################################\n" >> $LOGFILE
########################################################################################################################

# prep the output directory
mkdir ./abduction_output/1D 2>/dev/null
mkdir ./abduction_output/1D/runs 2>/dev/null
touch ./abduction_output/1D/tmp-$MODELNAME-executedBefore.tmp ./abduction_output/1D/output-$MODELNAME-consistentAbductions.log ./abduction_output/1D/output-$MODELNAME-consistentAbductionsSummary.log

# clear stat counters
clearStatCounters

# for each consistent abduction from the 2D phase, repeat the same process of forcing&checking consistent abductions
# excepth with 1D abduction (sample/pick one value from the abduced interval for one parameter, and then only abduce
# the other parameter --> abducing only one interval/variable ~~> one dimension)
consistentlyAbduced2DvaluesToCheck=$(cat "./abduction_output/2D/output-$MODELNAME-consistentAbductionsSummary.log" | sed "s|.*;||")
i=0
for valuesToCheck in $consistentlyAbduced2DvaluesToCheck; do
    i=$((i+1))

    # extract variable constraints for X1 and X2
    if $DEBUG; then echo "## 1D check of: $valuesToCheck" >> $LOGFILE; fi
    varX1=$(echo "$valuesToCheck" | sed "s|,X2.*$||")
    varX2=$(echo "$valuesToCheck" | sed "s|^.*X1[^X]*X2|X2|")

    # sample a value from X2 (can be any value within the interval) --> lets take the middle of the interval
    sampledX2fact=""
    if [ $(echo "$varX2" | sed "s|[#\.]|\n|" | grep -c "X2") -eq 2 ]; then # 2x X2 means there is an interval
        lowBound=$(echo "$varX2" | sed "s|^X2#>=*\([^,]*\),.*$|\1|")
        rigtBound=$(echo "$varX2" | sed "s|^.*X2#=*<\(.*\)$|\1|")
        sampledX2fact=$(echo "sampledX2(X2):-X2.=.((($rigtBound) - ($lowBound)) / 2) + ($lowBound).")

    else    # 1x X2 means there is one constant
        sampledX2fact=$(echo "sampledX2(X2):-$varX2.")
    fi

    # make a new fact to restrict abduction to the sampled value of X2
    samplefact=$(echo "sample(X1,X2):-$varX1,sampledX2(X2).")

    # extend the query to force 1D abduction instead of 2D abduction
    extendedQuery="./tmp-query-$MODELNAME-extendedfor1D.tmp"
    echo "conf_ENABLED_SAMPLING." > $extendedQuery
    echo "$sampledX2fact" >> $extendedQuery
    echo "$samplefact" >> $extendedQuery

    # first run with 1D abduction
    echo "#show $ABDUCIBLE_PRED_W2PARAMS/2." > ./abduction_output/1D/tmp-$MODELNAME-addition.tmp
    echo "#abducible $ABDUCIBLE_PRED_W2PARAMS(X,Y)." >> ./abduction_output/1D/tmp-$MODELNAME-addition.tmp
    if ! $NO_RUN; then
        { /usr/bin/time -f "\n  real      %E\n  real [s]  %e\n  user [s]  %U\n  sys  [s]  %S\n  mem  [KB] %M\n  avgm [KB] %K" scasp -s0 --dcc $SCASP_ARGS "$MODEL" $INCLUDE_FILES ./abduction_output/1D/tmp-$MODELNAME-addition.tmp $QUERY $extendedQuery ; } > ./abduction_output/1D/runs/output-$MODELNAME-run1-model1D$i.log 2>&1
        CUR_PHASE_NUMBER_OF_EXECUTIONS=$((CUR_PHASE_NUMBER_OF_EXECUTIONS+1))
        echo -n "## execution time of run1-model1D$i: " >> $LOGFILE
        grep "  real      " ./abduction_output/1D/runs/output-$MODELNAME-run1-model1D$i.log | sed "s|  real      ||" >> $LOGFILE
    fi

    # start the 1D recursive runs
    anotherRun 2 "1D$i." ./abduction_output/1D/runs/output-$MODELNAME-run1-model1D$i.log "    " "./abduction_output/1D" "$QUERY $extendedQuery"
done

# process output files at the end
tmp=$(cat "./abduction_output/1D/output-$MODELNAME-consistentAbductionsSummary.log" | LC_ALL=C.UTF-8 sort | uniq -c | LC_ALL=C.UTF-8 sort -nr | sed "s|\([0-9]\) |\1;|" | sed "s| *||" )
echo "$tmp" > "./abduction_output/1D/output-$MODELNAME-consistentAbductionsSummary.log"

# copy stat counters and print
PHASE_1D_NUMBER_OF_MODELS=$CUR_PHASE_NUMBER_OF_MODELS
PHASE_1D_NUMBER_OF_SPURIOUS=$CUR_PHASE_NUMBER_OF_SPURIOUS
PHASE_1D_NUMBER_OF_CONSISTENT=$CUR_PHASE_NUMBER_OF_CONSISTENT
PHASE_1D_NUMBER_OF_DEPTH=$CUR_PHASE_NUMBER_OF_DEPTH
PHASE_1D_NUMBER_OF_EXECUTIONS=$CUR_PHASE_NUMBER_OF_EXECUTIONS
PHASE_1D_NUMBER_OF_DUPLICATES=$CUR_PHASE_NUMBER_OF_DUPLICATES
PHASE_1D_NUMBER_OF_REFINED=$CUR_PHASE_NUMBER_OF_REFINED
PHASE_1D_NUMBER_OF_RESULTS=$(cat "./abduction_output/1D/output-$MODELNAME-consistentAbductionsSummary.log" | grep -v "^$" | wc -l)

echo >> $LOGFILE
echo "1D phase stats" >> $LOGFILE
printStatCounters "$PHASE_1D_NUMBER_OF_MODELS" "$PHASE_1D_NUMBER_OF_SPURIOUS" "$PHASE_1D_NUMBER_OF_CONSISTENT" "$PHASE_1D_NUMBER_OF_DEPTH" "$PHASE_1D_NUMBER_OF_EXECUTIONS" "$PHASE_1D_NUMBER_OF_DUPLICATES" "$PHASE_1D_NUMBER_OF_RESULTS"

# mark end of the second part of the script in the output
echo -n "DATE: " >> $LOGFILE; date >> $LOGFILE


########################################################################################################################


# sum all stat counters and print
TOTAL_NUMBER_OF_MODELS=$((PHASE_2D_NUMBER_OF_MODELS+PHASE_1D_NUMBER_OF_MODELS))
TOTAL_NUMBER_OF_SPURIOUS=$((PHASE_2D_NUMBER_OF_SPURIOUS+PHASE_1D_NUMBER_OF_SPURIOUS))
TOTAL_NUMBER_OF_CONSISTENT=$((PHASE_2D_NUMBER_OF_CONSISTENT+PHASE_1D_NUMBER_OF_CONSISTENT))
TOTAL_NUMBER_OF_DEPTH=$((PHASE_2D_NUMBER_OF_DEPTH+PHASE_1D_NUMBER_OF_DEPTH))
TOTAL_NUMBER_OF_EXECUTIONS=$((PHASE_2D_NUMBER_OF_EXECUTIONS+PHASE_1D_NUMBER_OF_EXECUTIONS))
TOTAL_NUMBER_OF_DUPLICATES=$((PHASE_2D_NUMBER_OF_DUPLICATES+PHASE_1D_NUMBER_OF_DUPLICATES))
TOTAL_NUMBER_OF_RESULTS=$((PHASE_2D_NUMBER_OF_RESULTS+PHASE_1D_NUMBER_OF_RESULTS))
TOTAL_NUMBER_OF_REFINED=$((PHASE_2D_NUMBER_OF_REFINED+PHASE_1D_NUMBER_OF_REFINED))

echo >> $LOGFILE
echo "Total stats" >> $LOGFILE
printStatCounters "$TOTAL_NUMBER_OF_MODELS" "$TOTAL_NUMBER_OF_SPURIOUS" "$TOTAL_NUMBER_OF_CONSISTENT" "$TOTAL_NUMBER_OF_DEPTH" "$TOTAL_NUMBER_OF_EXECUTIONS" "$TOTAL_NUMBER_OF_DUPLICATES" "$TOTAL_NUMBER_OF_RESULTS" "$TOTAL_NUMBER_OF_REFINED"


# create the results files
cp ./abduction_output/1D/output-$MODELNAME-consistentAbductionsSummary.log ./abduction_output/result-$MODELNAME-summary.log
cp ./abduction_output/1D/output-$MODELNAME-consistentAbductions.log ./abduction_output/result-$MODELNAME-detail.log

# print the actual result of the initial query
echo "Number of valid model witnesses for the initial query: $PHASE_1D_NUMBER_OF_RESULTS" >> $LOGFILE

# output the final models in scasp style
rm -f ./abduction_output/result-$MODELNAME-models.log
if [ $PHASE_1D_NUMBER_OF_RESULTS -ge 1 ]; then
    # look up each model in its corresponding output file
    modelNumInFilePerLine=$(cat ./abduction_output/result-$MODELNAME-detail.log | sed "s|.*model number: [^;]*\([0-9][0-9]*\);|\1;|" | sed "s| from: ||")
    for modelNumInFile in $modelNumInFilePerLine; do
        modelNumber=$(echo "$modelNumInFile" | sed "s|;.*$||")
        modelFile=$(echo "$modelNumInFile" | sed "s|.*;||")
        cat "$modelFile" | grep -A4 -m$modelNumber MODEL: | tail -n5 | tee -a ./abduction_output/result-$MODELNAME-models.log
        echo
    done
else
    echo -e "\nno models\n" | tee -a ./abduction_output/result-$MODELNAME-models.log
fi

# clean up and exit
if $DEBUG; then exit
else 
    rm -f ./abduction_output/2D/tmp-$MODELNAME-addition.tmp ./abduction_output/2D/tmp-$MODELNAME-executedBefore.tmp
    rm -f ./abduction_output/1D/tmp-$MODELNAME-addition.tmp ./abduction_output/1D/tmp-$MODELNAME-executedBefore.tmp ./tmp-query-$MODELNAME-extendedfor1D.tmp
    exit;
fi