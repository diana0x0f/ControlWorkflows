#!/usr/bin/env bash

# set -x;
set -e;
set -u;

QC_GEN_CONFIG_PATH='json://'`pwd`'/etc/emc-qc-post-calib.json'
QC_FINAL_CONFIG_PATH='consul-json://{{ consul_endpoint }}/o2/components/qc/ANY/any/{{ qc_json_file }}'
QC_CONFIG_PARAM='qc_config_uri'
QC_JSON_FILE='qc_json_file'
QC_JSON_FILE_DEFAULT='emc-qc-post-calib'


source helpers.sh

cd ../

WF_NAME=emc-qc-post-calib-remote


o2-qc --config $QC_GEN_CONFIG_PATH --remote -b --o2-control $WF_NAME

# add the templated QC config file path
ESCAPED_QC_FINAL_CONFIG_PATH=$(printf '%s\n' "$QC_FINAL_CONFIG_PATH" | sed -e 's/[\/&]/\\&/g')
sed -i /defaults:/\ a\\\ \\\ "${QC_JSON_FILE}":\ \""${QC_JSON_FILE_DEFAULT}"\" workflows/${WF_NAME}.yaml
#sed -i /defaults:/\ a\\\ \\\ "${QC_CONFIG_PARAM}":\ \""${ESCAPED_QC_FINAL_CONFIG_PATH}"\" workflows/${WF_NAME}.yaml



# find and replace all usages of the QC config path which was used to generate the workflow
ESCAPED_QC_GEN_CONFIG_PATH=$(printf '%s\n' "$QC_GEN_CONFIG_PATH" | sed -e 's/[]\/$*.^[]/\\&/g');
sed -i "s/""${ESCAPED_QC_GEN_CONFIG_PATH}""/""${ESCAPED_QC_FINAL_CONFIG_PATH}""/g" workflows/${WF_NAME}.yaml tasks/${WF_NAME}-*