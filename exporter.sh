#!/bin/bash
set -e
set -u
set -o pipefail

AUTH_KEY="GRAFANA API-KEY HERE"
ENDPOINT="GRAFANA ADDRESS HERE"
GRAFANA_DASHBOARDS_FOLDER="dashboards"


echo "Exporting Grafana dashboards from $ENDPOINT"

mkdir -p "${GRAFANA_DASHBOARDS_FOLDER}"

for dash in $(curl -sSL -k -H "Authorization: Bearer ${AUTH_KEY}" "${ENDPOINT}/api/search?query=&" | jq -r '.[] | select(.type == "dash-db") | .uid'); do
  DASH_DUMP=$(curl -sSL -k -H "Authorization: Bearer ${AUTH_KEY}" "${ENDPOINT}/api/dashboards/uid/$dash" | jq -r .)
  FILE_NAME=`echo ${DASH_DUMP} | jq -r '.meta.slug'`
  echo ${FILE_NAME} "exported successfully"
  FOLDER_NAME=`echo ${DASH_DUMP} | jq -r '.meta.folderTitle'`
  echo ${DASH_DUMP} | jq -r .dashboard > ${GRAFANA_DASHBOARDS_FOLDER}/${dash}.json
  mkdir -p "${GRAFANA_DASHBOARDS_FOLDER}/${FOLDER_NAME}"
  mv ${GRAFANA_DASHBOARDS_FOLDER}/${dash}.json "${GRAFANA_DASHBOARDS_FOLDER}/${FOLDER_NAME}/${FILE_NAME}.json"
done