# The AWS CodeBuild team don't seem to tag the releases of the local build
# image, so we're forced to pull `latest`.  This is less than ideal because at
# some point `latest` will no longer require this fix, and the wholesale
# replacement of `local_build.sh` will eventually break.

from amazon/aws-codebuild-local:latest
add local_build.sh /usr/local/bin/local_build.sh
