JIRA_USER=
JIRA_PASS=

JIRA_TOKEN=$(echo -n "$JIRA_USER:$JIRA_PASS" | base64)

JIRA_DOMAIN=aa.atlassian.net
ISSUE_PATTERN="AA-[0-9]+"

jira:get_global_status()
{
    curl --silent \
        --request GET \
        --header "Authorization: Basic ${JIRA_TOKEN}" \
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
        --header "Authorization: Basic ${JIRA_TOKEN}" \
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
        --header "Authorization: Basic ${JIRA_TOKEN}" \
        --header 'Content-Type: application/json' \
        --url "https://${JIRA_DOMAIN}/rest/api/2/issue/${issue_key}"
}


jira:issue_get_transitions()
{
    local issue_key=$1
    curl \
        --silent \
        --request GET \
        --header "Accept: application/json" \
        --header "Authorization: Basic ${JIRA_TOKEN}" \
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
        --header "Authorization: Basic ${JIRA_TOKEN}" \
        --header 'Content-Type: application/json' \
        --data "{ \"transition\": { \"id\": ${transition_id} } }" \
        --url "https://${JIRA_DOMAIN}/rest/api/2/issue/${issue_key}/transitions"
}
