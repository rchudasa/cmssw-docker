#!/bin/bash

files=$(git diff-tree --no-commit-id --name-only -r -m $CI_COMMIT_SHA) # Get path to files changed in commit
regexp="cc7-cms\|cc7-cvmfs\|slc6-cms\|slc6-cvmfs\|slc5-cms"
if [[ ! -z $CI_COMMIT_BRANCH ]]; then
  regexp="${regexp}\|standalone"
fi

dir_wo_duplicates=$(echo $files | grep -o $regexp | sort | uniq | tr '\n' ' ' | sed -e 's/[[:space:]]*$//') # Directories without duplicates
for dir in $dir_wo_duplicates; do

  if  [[ -z $CI_COMMIT_BRANCH ]]; then # $CI_COMMIT_BRANCH is the commit branch name. Present only when building branches.
    # For production on master

    echo "On master"
    echo "Triggered build of $dir"

    curl --request POST \
    --form token=$CI_JOB_TOKEN \
    --form ref=$CI_DEFAULT_BRANCH \
    --form "variables[IMAGE_NAME]=$dir" \
    https://gitlab.cern.ch/api/v4/projects/$CI_PROJECT_ID/trigger/pipeline

  elif [[ ! -z $CI_COMMIT_BRANCH ]]; then
    # For testing on branches

    echo "On branch $CI_COMMIT_BRANCH"
    echo "Triggered build of $dir"

    curl --request POST \
    --form token=$CI_JOB_TOKEN \
    --form ref=$CI_COMMIT_BRANCH \
    --form "variables[IMAGE_NAME]=$dir" \
    --form "variables[TEST]=TEST" \
    https://gitlab.cern.ch/api/v4/projects/$CI_PROJECT_ID/trigger/pipeline
  
  fi
done
