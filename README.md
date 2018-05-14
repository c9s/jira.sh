# jira.sh

JIRA Client for shell scripts.


## Setting up

Go to your profile to get an API token
<https://id.atlassian.com/manage/api-tokens>:

```sh
export JIRA_USER="myaccount@gmail.com"
export JIRA_PASS="your-token-here"

export JIRA_DOMAIN="yoursite.atlassian.net"
export JIRA_PROJECT_CODE="ST"
```

## Source Library

```sh
source jira.sh
```

## Using Functions

Add comment to an issue:

```sh
jira:issue_add_comment "AA-999" "Hello World"
```

Check if an issue is sub-task:

```sh
if [[ $(issue_is_subtask "AA-999") == "true" ]] ; then
    echo "is subtask"
if
```

Get available transitions of an issue:

```sh
jira:issue_get_transitions "AA-999"
```

Do the transition of an issue:

```sh
jira:issue_do_transition "$issue_key" "$tx_id"
```


