
.PHONY: image
image:
	docker build -t sinistral/aws-codebuild-local:issue-73 .
