## Bootstrap

1. **Create S3 bucket for Terraform state**

    ```shell
    aws s3api create-bucket \
        --bucket m8rmclaren-terraform-state-infra \
        --region us-west-1 \
        --create-bucket-configuration LocationConstraint=us-west-1
    ```

    > If region or bucket name is changed, corresponding change is necessary in Terraform code

