#!/bin/bash

INSTANCE=
DATABASE=
TABLE_NAME=
BUCKET=csv-startrek-

REGION=us-west4
LOCATION=regional-${REGION}

#DDL_FILE=create_table.ddl

gcloud services enable spanner.googleapis.com dataflow.googleapis.com

gcloud spanner instances create $INSTANCE --config=$LOCATION --description=$INSTANCE --nodes=1

gcloud spanner databases create $DATABASE --instance=$INSTANCE --database-dialect=GOOGLE_STANDARD_SQL --ddl="CREATE TABLE ${TABLE_NAME} (ShipName STRING(200),Registry STRING(200),ShipClass STRING(200),Description STRING(2560),) PRIMARY KEY(Registry);"

sed 's|'csv-startrek-XXXXX'|'"$BUCKET"'|g' startrek.start  > startrek.1
sed 's|'YYYYY'|'"$TABLE_NAME"'|g' startrek.1  > startrek.json


gsutil cp startrek.json gs://${BUCKET}/ 

gcloud dataflow jobs run $INSTANCE \
    --gcs-location gs://dataflow-templates/latest/GCS_Text_to_Cloud_Spanner \
    --region $REGION \
    --parameters \
instanceId=$INSTANCE,\
databaseId=$DATABASE,\
importManifest=gs://${BUCKET}/startrek.json

