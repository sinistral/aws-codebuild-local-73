## amazon/aws-codebuild-local

Build a patched `aws-codebuild-local` Docker image for [#73].

Update your `codebuild_build.sh` accordingly

```diff
diff --git a/local_builds/codebuild_build.sh b/local_builds/codebuild_build.sh
index 5a2b917..51a900a 100755
--- a/local_builds/codebuild_build.sh
+++ b/local_builds/codebuild_build.sh
@@ -93,7 +93,7 @@ then
     docker_command+="$(env | grep ^AWS_ | while read -r line; do echo " -e \"$line\""; done )"
 fi

-docker_command+=" amazon/aws-codebuild-local:latest"
+docker_command+=" sinistral/aws-codebuild-local:issue-73"

 # Note we do not expose the AWS_SECRET_ACCESS_KEY or the AWS_SESSION_TOKEN
 exposed_command=$docker_command
 ```

[#73]: https://github.com/aws/aws-codebuild-docker-images/issues/73
