#!/bin/bash

set -eu

if [[ -z "$ENABLE_ERRANDS" ]]; then
  echo Nothing to do.
  exit 0
fi

if [[ "$ENABLE_ERRANDS" == "true" ]]; then
  toggle_state=enabled
elif [[ "$ENABLE_ERRANDS" == "false" ]]; then
  toggle_state=disabled
else
  echo "Invalid argument: $ENABLE_ERRANDS. Valid states: true | false"
  exit 1
fi

product_errands=$(
  om-linux \
    --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
    --skip-ssl-validation \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "$OPSMAN_USERNAME" \
    --password "$OPSMAN_PASSWORD" \
    errands \
    --product-name "$PRODUCT_NAME" | egrep '^\| [a-z]+' | cut -d" " -f 2
)

while read errand; do
  echo "toggling $errand state..."
  om-linux \
    --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
    --skip-ssl-validation \
    --client-id "${OPSMAN_CLIENT_ID}" \
    --client-secret "${OPSMAN_CLIENT_SECRET}" \
    --username "$OPSMAN_USERNAME" \
    --password "$OPSMAN_PASSWORD" \
    set-errand-state \
    --product-name "$PRODUCT_NAME" \
    --errand-name $errand \
    --post-deploy-state "${toggle_state}"
  echo -n $toggle_state $errand...
done < <(echo "$product_errands")
