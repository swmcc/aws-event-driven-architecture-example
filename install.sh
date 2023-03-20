#/usr/bin/env bash

## TODO: Finish this off.

set -eo pipefail

export AWS_PROFILE=XXXXXX
export AWS_DEFAULT_REGION=XXXXXX

function has_param() {
  local terms="$1"
  shift

  for term in $terms; do
    for arg; do
      if [[ $arg == "$term" ]]; then
        echo "yes"
      fi
    done
  done
}

if [[ -n $(has_param "-h --help" "$@") ]]; then
cat <<-OUTPUT
  usage [--version] [--help]

  You can create a stack with the following

  --setup Creates the archives, uploads the zip archives to the S3 Bucket. Then deploys the lambdas, triggers and provisions a database.

OUTPUT
fi

if [[ -n $(has_param "--setup" "$@") ]]; then
  echo "Starting setup ☀️"
  echo "Creating Archives... 🖥"
  rm -rf build
  mkdir build
  zip -jr build/image_processor.zip image_processor/*
  zip -jr build/upload_listener.zip upload_listener/*
  echo "Finished Creating Archives 🏁"

  echo "Creating stacks... 🥞"
  echo "Deploying Lambdas, creating triggers and provisioing database... 🚀🐑🔫💽"
    aws cloudformation create-stack \
    --stack-name image-processing-example-resources \
    --capabilities CAPABILITY_IAM \
    --template-body "$(cat cfn/resources.yaml)"
fi

if [[ -n $(has_param "-v --version" "$@") ]]; then
  echo "aws-event-driven-architecture-example 0.0.1 (Mac/Linux)"
fi
