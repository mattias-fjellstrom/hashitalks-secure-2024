#!/bin/bash

BUCKET=$(terraform output -raw s3_bucket_name)
aws s3 rm s3://$BUCKET/ --recursive