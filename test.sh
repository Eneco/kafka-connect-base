#
# Tests for the liveness probe that checks for failed tasks running on this
# worker.
#

TEST_INPUT_FILE=test_inputs.json
NUM_TESTS=$(cat "$TEST_INPUT_FILE" | jq 'length')

echo "Running tests:"
for (( test=0; test<$NUM_TESTS; test++ ))
do
    NAME=$(cat "$TEST_INPUT_FILE" | jq ".[$test].name")
    STATUS=$(cat "$TEST_INPUT_FILE" | jq ".[$test].status")
    WORKER_ID=$(cat "$TEST_INPUT_FILE" | jq ".[$test].worker_id")
    RESULT=$(cat "$TEST_INPUT_FILE" | jq ".[$test].result")

    echo $NAME
    bash ./liveliness.sh --test "$STATUS" "$WORKER_ID"
    if [ $? == $RESULT ]
    then
      echo PASSED
    else
      echo FAILED
      exit 1
    fi
done
exit 0
