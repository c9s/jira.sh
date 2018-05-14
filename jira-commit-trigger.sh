#!/bin/bash
dirname=$(dirname $0)
source $dirname/config.sh
source $dirname/jira.sh

LOG_RANGE=$1

if [[ -z "$LOG_RANGE" ]]
then
    echo "commit range is required."
    exit 1
fi


if [[ -z "$JIRA_USER" ]]
then
    echo "JIRA_USER is required."
    return
fi

if [[ -z "$JIRA_PASS" ]]
then
    echo "JIRA_PASS is required."
    return
fi

if [[ -z "$JIRA_DOMAIN" ]]
then
    echo "JIRA_DOMAIN is required."
    return
fi


git log --extended-regexp --grep "$(jira:issue_pattern $JIRA_PROJECT_CODE)" --format=%h "$LOG_RANGE" | while read commit_hash
do
    commit_full=$(git --no-pager log -1 $commit_hash)
    commit_body=$(git --no-pager log --format=%b -1 $commit_hash)
    echo "Processing commit '$commit_hash'..."
    git --no-pager log --format=%b -1 $commit_hash \
        | grep -E -o "$(jira:issue_pattern $JIRA_PROJECT_CODE)" | uniq \
        | while read matches
    do
        # Expand matches
        for issue_key in ${matches[*]}
        do
            echo "Found linked issue: $issue_key"

            echo "Adding comment..."
            jira:issue_add_comment "$issue_key" "deployed to $SITE_NAME site $SITE_URL." > /dev/null

            # for subtask, we transite the task to close once it's deployed
            if [[ $(issue_is_subtask "$issue_key") == "true" ]]
            then
                # jira:issue_get_transitions "$issue_key" | json_pp
                tx_id=$(jira:issue_get_transitions "$issue_key" | jira:find_transition_by_name "Close Issue")
                if [[ -n $tx_id ]]
                then
                    echo "Found transition available: '$tx_id'"
                    echo "Do transition: $tx_id"
                    jira:issue_do_transition "$issue_key" "$tx_id"
                fi
            fi
        done
    done
done
