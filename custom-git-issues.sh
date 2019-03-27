#!/bin/bash

# Delete default labels
ghi label -D "bug"
ghi label -D "todo"
ghi label -D "Todo"
ghi label -D "help wanted"
ghi label -D "enhancement"
ghi label -D "duplicate"
ghi label -D "good first issue"
ghi label -D "invalid"
ghi label -D "question"
ghi label -D "task"
ghi label -D "wontfix"


# Create our new / custom labels
ghi label "Action - awaiting feedback"   -c FFFF00
ghi label "Action - needs grooming"      -c FFFF00
ghi label "Action - no action needed"    -c FF00FF
ghi label "Priority 1 - must have"       -c d73a4a
ghi label "Priority 2 - should have"     -c d73a4a
ghi label "Priority 3 - could have"      -c d73a4a
ghi label "Priority 4 - won't have"      -c d73a4a
ghi label "Size 0 - briefing / question" -c f7dab7
ghi label "Size 1 - small (~2 hours)"    -c f7dab7
ghi label "Size 2 - medium (~half day)"  -c f7dab7
ghi label "Size 3 - large (~full day)"   -c f7dab7
ghi label "Size 4 - too big"             -c f7dab7
ghi label "Status - duplicate"           -c c7def8
ghi label "Status - workable"            -c c7def8
ghi label "Status - in progress"         -c c7def8
ghi label "Status - up next"             -c c7def8

