#/bin/bash
PROJID=`gcloud config list --format 'value(core.project)' 2>/dev/null`

echo "this is the project"
echo $PROJID
