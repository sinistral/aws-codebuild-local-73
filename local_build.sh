#!/bin/sh

cd /LocalBuild/agent-resources

if [ $IS_INNER_CONTAINER == true ]
then
    if [ ! -z "${BUILDSPEC_PATH}" ]
    then
        RELATIVE_PATH=${BUILDSPEC_PATH}
        if [[ ${BUILDSPEC_PATH} = *"$SOURCE_PATH"* ]]
        then
            TEMP=${BUILDSPEC_PATH#$SOURCE_PATH}
            RELATIVE_PATH=${TEMP#"/"}
        fi
        echo ${RELATIVE_PATH} > /codebuild/input/buildspec.yml
    fi
    touch /codebuild/output/log
    tail -F /codebuild/output/log &
    sh ./start > /dev/null
else
    AGENT_ID=$(docker ps | sed -n 2p | cut -c 1-12)
    export LOCAL_AGENT_IMAGE=$(docker inspect --format='{{.Config.Image}}' ${AGENT_ID})

    export CODEBUILD_LOCAL_SOURCE_DIRECTORY=${SOURCE}
    export IMAGE_FOR_CODEBUILD_LOCAL_BUILD=${IMAGE_NAME}
    export CODEBUILD_LOCAL_ARTIFACTS_DIRECTORY=${ARTIFACTS}
    export CODEBUILD_LOCAL_BUILDSPEC_PATH=${BUILDSPEC}

    cp docker-compose.yml customer-specific.yml

    # Environment variable file has precedent over AWS Configuration. Any AWS config variables in both the customers local space
    # and their environment variable file will receive the value from the file. This is maintained by ensuring that we set the
    # file variables after we set up the customers AWS Configuration.
    if [ ! -z "${AWS_CONFIGURATION}" ]
    then
        if [[ "$AWS_CONFIGURATION" = *".aws"* ]]
        then
            /LocalBuild/agent-resources/bin/edit-docker-compose ${AWS_CONFIGURATION} /LocalBuild/agent-resources/customer-specific.yml "AWSConfiguration"
        fi
        printenv | grep -v AWS_CONFIGURATION | grep AWS_ > awsconfig.txt
        /LocalBuild/agent-resources/bin/edit-docker-compose awsconfig.txt /LocalBuild/agent-resources/customer-specific.yml "EnvironmentVariables"
    fi

    if [ ! -z "${ENV_VAR_FILE}" ]
    then
        /LocalBuild/agent-resources/bin/edit-docker-compose /LocalBuild/envFile/$ENV_VAR_FILE /LocalBuild/agent-resources/customer-specific.yml "EnvironmentVariables"
    fi

    # Validate docker-compose config
    docker-compose -f customer-specific.yml config --quiet || exit 1

    # Clean up any previous runs
    docker-compose -f customer-specific.yml down -v

    # Start
    docker-compose -f customer-specific.yml up --abort-on-container-exit | tee build_logs
    if grep -q "Phase complete: [A-Z_]* Success: false" build_logs
    then
        exit 1
    else
        exit 0
    fi

fi
