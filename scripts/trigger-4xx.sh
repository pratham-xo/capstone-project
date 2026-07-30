#!/bin/bash
ALB_DNS="test-alb-tf-1518819788.ap-south-1.elb.amazonaws.com"
BAD_PATH="/this-path-does-not-exist"
COUNT=${1:-50}

echo "Sending $COUNT requests to http://$ALB_DNS$BAD_PATH"
for i in $(seq 1 $COUNT); do
  code=$(curl -s -o /dev/null -w "%{http_code}" "http://$ALB_DNS$BAD_PATH")
  echo "Request $i: $code"
  sleep 1
done
