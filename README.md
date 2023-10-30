# Packer Automation

## About the Project

This project represents a [Packer](https://www.packer.io/) automation for creating a custom machine image with a `.NET Core Application` installed. It uses AWS as the cloud provider and involves the use of several AWS resources, including `AMIs`, `EC2 instances`, and an `S3 bucket`.

The `S3 Bucket` is used for the following purposes:
- Storing the .NET Application package.
- Storing a `bootstrap_win` file used when creating the AMIs.
- Serving as a backend for storing the Terraform state. This allows you to use Terraform both through GitHub Actions and locally.

The project is divided into two parts:
1. Image creation using `Packer`.
2. Virtual Machine provisioning using `Terraform`.

For this project, three `GitHub Actions` pipelines have been defined:
1. **Packer pipeline**
2. **AWS EC2 Deploy pipeline**
3. **AWS EC2 Cleanup pipeline**

## Packer Pipeline

This pipeline is also divided into two steps:
1. First, we create a custom Windows image using a base Windows Server 2022 image from Amazon as the source image. We install the prerequisites for running the application, which can be seen as the First Layer (`Prerequisites Layer`).
2. Secondly, we create another image using the First Layer image created in the first step, and we install the `.NET application`. For simplicity, the application is installed as a Windows Service that automatically starts at boot, which can be seen as the Second Layer (`Application Layer`).

### Prerequisites

The pipeline downloads a `bootstrap_win.txt` file from the `S3 Bucket` because the Windows base image does not automatically allow ingress traffic. This script runs on the build instance at launch and allows connections over `WinRM`. In this repository, you can find an example of it and modify the username and password as needed.

The pipeline also downloads a zip package named `DevopsWebApp.zip` containing the `.NET application` from the `S3 Bucket`, which was uploaded by another CI pipeline. If you want to use Packer locally, make sure to have the zip file in your directory.

For the `Prerequisites Layer`, the script `install_dotnet_prerequisites.ps1` installs everything needed to run the `.NET application`.

For the `Application Layer`, the script `install_dotnet_application.ps1` installs the application as a Windows Service.

This is used as an example for a `.NET application`, but you can easily modify these scripts as needed.

## AWS EC2 Deploy Pipeline

This pipeline uses `Terraform` to provision `EC2 instances` using the Application Image created using the `Packer` pipeline. You can select the number of instances you want to deploy.

## AWS EC2 Cleanup Pipeline

This pipeline uses `Terraform` to destroy the resources deployed using the other pipeline to avoid unnecessary costs in AWS. By using the `S3 bucket` as a backend for `Terraform`, the pipeline retrieves the state of the deployed resources and can easily delete all of them with just a single click.

## Usage

### **Local Usage**

If you want to run this project on your local machine, please make sure that you have [Packer](https://developer.hashicorp.com/packer/downloads?product_intent=packer) and [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed.

1. **Packer**

    If you want to use Packer on your local machine, you can follow these steps:
    
    1. Clone the repository
        ```sh
        git clone repoURL
        ```
    2. Navigate to the solution directory
        ```sh
        cd RepoName
        ```
    3. Complete the variables block in each `.hcl` file. You can also set the AWS credentials as environment variables.
         ```sh
        variables {  
            access_key=""
            secret_key=""
            instance_type=""
            region=""
            winrm_password=""
            winrm_username=""
        }
        ```
    4. Run `packer init` to download Packer plugin binaries
        ```sh
        packer init aws-base-windows.pkr.hcl
        packer init aws-application-windows.pkr.hcl
        ```
    5. Build the prerequisites image
        ```sh
        packer build aws-base-windows.pkr.hcl
        ```
    6. Build the application image
        ```sh
        packer build aws-application-windows.pkr.hcl
        ```
       

2. **AWS EC2 Deploy**

    If you want to deploy `EC2 instances` in `AWS` using your local machine, follow these steps:

    1. Clone the repository
        ```sh
        git clone repoURL
        ```
    2. Navigate to the `Terraform` directory
        ```sh
        cd RepoName/Terraform
        ```
    3. Configure your `AWS` environment variables
        ```sh
        export AWS_ACCESS_KEY_ID={your_access_key_id}
        export AWS_SECRET_ACCESS_KEY={your_secret_access_key}
        export AWS_DEFAULT_REGION={your_default_region}
        ```
    4. Run `Terraform init`
        ```sh
        terraform init
        ```
    5. Set the number of `EC2 instances` you want to deploy (default value is 1)
        ```sh
        export instance_count={value} 
        ```
    6. Plan your deployment
        ```sh
        terraform plan -var "instance_count=$instance_count"
        ```
    7. If the plan's output is okay, you can apply the changes
        ```sh
        terraform apply -var "instance_count=$instance_count" --auto-approve
        ```

3. **AWS EC2 Cleanup**

    If you want to destroy the deployed resources in `AWS` using your local machine, you can follow these steps (assuming you already completed the first four steps while deploying resources):

    8. Destroy the resources
        ```sh
        terraform destroy --auto-approve
        ```

### **GitHub Actions Usage**

**Configure Secrets and Variables**

Since all pipelines use `AWS`, you need to define the following variables and secrets for your repository:

1. Secrets
    ```js
    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY
    WINRM_PASSWORD
    ```
2. Variables
    ```js
    AWS_BUCKET
    INSTANCE_TYPE
    REGION
    WINRM_USERNAME
    ```

Each pipeline has a `Run workflow` button for starting the pipeline. The `AWS EC2 Deploy pipeline` also has an input for choosing the number of `VMs` you want to deploy.
