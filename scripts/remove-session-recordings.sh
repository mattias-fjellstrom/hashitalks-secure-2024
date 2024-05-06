#!/bin/bash

BUCKET=$1
aws s3 rm s3://$BUCKET/ --recursive