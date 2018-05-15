#!/bin/bash
jira:issue_pattern()
{
    local code=$1
    echo "${code}-[0-9]+"
}

jira:token()
{
    echo -n "$JIRA_USER:$JIRA_PASS" | base64
}

jira:get_global_status()
{
    curl --silent \
        --request GET \
        --header "Authorization: Basic $(jira:token)" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        "https://$JIRA_DOMAIN/rest/api/2/status"
}

jira:find_status_by_name()
{
    local name=$1
    cat | jq -r ".[] | select(.name == \"$name\") | .[0].id"
}

jira:find_transition_by_status_name()
{
    local name=$1
    cat | jq -r ".transitions[] | select(.to.name == \"$name\") | .[0].id"
}

jira:find_transition_by_name()
{
    local name=$1
    cat | jq -r ".transitions[] | select(.name == \"$name\") | .id"
}


jira:issue_add_comment()
{
    local issue_key=$1
    local comment=$2
    curl \
        --silent \
        --request POST \
        --header "Accept: application/json" \
        --header "Authorization: Basic $(jira:token)" \
        --header 'Content-Type: application/json' \
        --data "{ \"body\": \"${comment}\" }" \
        --url "https://${JIRA_DOMAIN}/rest/api/2/issue/${issue_key}/comment"
}

jira:issue()
{
    local issue_key=$1
    curl \
        --silent \
        --request GET \
        --header "Accept: application/json" \
        --header "Authorization: Basic $(jira:token)" \
        --header 'Content-Type: application/json' \
        --url "https://${JIRA_DOMAIN}/rest/api/2/issue/${issue_key}"
}

jira:issue_is_story()
{
    local issue_key=$1
    jira:issue $issue_key | jq -r '.fields.issuetype.name == "Story"'
}

jira:issue_is_bug()
{
    local issue_key=$1
    jira:issue $issue_key | jq -r '.fields.issuetype.name == "Bug"'
}

jira:issue_is_subtask()
{
    local issue_key=$1
    jira:issue $issue_key | jq -r ".fields.issuetype.subtask"
}


jira:issue_get_transitions()
{
    local issue_key=$1
    curl \
        --silent \
        --request GET \
        --header "Accept: application/json" \
        --header "Authorization: Basic $(jira:token)" \
        --header 'Content-Type: application/json' \
        --url "https://${JIRA_DOMAIN}/rest/api/2/issue/${issue_key}/transitions"
}

jira:issue_do_transition()
{
    local issue_key=$1
    local transition_id=$2
    curl \
        --silent \
        --request POST \
        --header "Accept: application/json" \
        --header "Authorization: Basic $(jira:token)" \
        --header 'Content-Type: application/json' \
        --data "{ \"transition\": { \"id\": ${transition_id} } }" \
        --url "https://${JIRA_DOMAIN}/rest/api/2/issue/${issue_key}/transitions"
}
