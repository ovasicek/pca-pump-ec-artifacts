#!/bin/sh

ROOTDIR="$(dirname "$(realpath "$0")")"
cd "$ROOTDIR"

MODEL_NAME="./model_sources/model-base.pl"
SOURCE_FILES="./model_sources/*.pl"

# clear the output file
echo "" > $MODEL_NAME-preprocessed.pl

# create "can_something(event, fluent)." for rules like "initiates(event1, fluent1, T) :- holdsAt(...), happens(...), ... ."
cat $SOURCE_FILES | grep -v " %//NO_PREPROCESS" | grep -E "^ *(or_initiates|or_terminates|or_releases)" | sed -E "s| *:-.*$|.|" | sed -E "s/or_(initiates|terminates|releases)/can_\1/g" | sed -E "s|, *T *\)|)|g" >> $MODEL_NAME-preprocessed.pl

# create "can_trajectory(fluent1, T1, fluent2, T2)." for rules like "trajectory(fluent1, T1, fluent2, T2) :- holdsAt(...), happens(...), ... ."
cat $SOURCE_FILES | grep -v " %//NO_PREPROCESS" | grep -E "^ *or_trajectory" | sed -E "s| *:-.*$|.|" | sed -E "s|or_trajectory|can_trajectory|g" >> $MODEL_NAME-preprocessed.pl

sorted=$(cat $MODEL_NAME-preprocessed.pl | LC_ALL=C.UTF-8 sort | uniq)
echo "$sorted" > $MODEL_NAME-preprocessed.pl