terraform commented in main.tf


terraform init
terraform apply

If you want to use s3 as share storage for modify tf state and lock
uncoment terraform in main.tf


terraform init -backend-config=backend.hcl

If you want to go back and use local storage for tf state and lock
comment terraform in main.tf


terraform init -migrate-state
