# orbit

Welcome to the OpenStack Terraform Configuration project! This guide will help you set up a basic cloud infrastructure using Terraform and OpenStack, on ServerCore cloud.

## What does this project do?

This project uses Terraform to automatically set up cloud resources using OpenStack provider. 

Here's what it creates:

- A virtual machine (we call this a "compute instance")
- A hard drive for the virtual machine (block storage)
- A private network for your resources
- A way for your virtual machine to connect to the internet
- Security settings to keep your virtual machine safe

## Repository Structure

- **frontend**: Has the react application
- **/.github/workflows**: Contains scripts for CI/CD integration and other automation tasks.
- **/Docs**: Folder contains a solutions architect document with more detailed documentation on ServerCore and openstack.
- **main.tf**: Main file for infrastructure provisioning- **provisioners.tf**: provisioning.

## Before you start

You'll need a few things set up on your computer:

1. **Terraform**: This is the tool we use to create our cloud resources. [Download and install Terraform](https://www.terraform.io/downloads.html) (version 0.12.x or later).
2. **ServerCore**: You need an account with ServerCore cloud provider https://my.servercore.com/login.
3. **openstack**: You need to install openstack cli on your local machine.

## Step-by-step guide

### 1. Get your OpenStack credentials

First, we need to get your OpenStack credentials. These are like a special key that lets Terraform talk to your SrrverCore account.

To get your credentials from ServerCore:

1. Log in to your ServerCore dashboard.
2. Look for a section called "Access".
3. Download the RC file (it should be named something like `project-openrc.sh`).
4. Open the file with a text editor.
5. Look for lines that start with `export OS_`. These are your OpenStack environment variables.

### 2. Set up your environment

Now, we need to tell your computer about these credentials:

## Option 1: Use the source command (Recommended)

1. Open a terminal (Command Prompt on Windows, Terminal on Mac/Linux).
2. Navigate to the directory where you downloaded the RC file.
3. Run the following command:
    
    `source project-openrc.sh`
    
    Replace `project-openrc.sh` with the actual name of your RC file.
4. When prompted, enter your ServerCore password.

This method automatically sets up all the necessary environment variables for you.

## Option 2: Manual setup

1. Open a terminal (Command Prompt on Windows, Terminal on Mac/Linux).
2. For each line in the RC file that starts with `export OS_`, type it into your terminal and press Enter. For example:
    
    `export OS_AUTH_URL=https://your-openstack-auth-url export OS_PROJECT_ID=your-project-id export OS_PROJECT_NAME="Your Project Name" export OS_USER_DOMAIN_NAME="Default" export OS_USERNAME="your-username" export OS_PASSWORD="your-password" export OS_REGION_NAME="your-region"`
    
    Note: For the `OS_PASSWORD`, you'll need to type in your actual ServerCore password.

### 3. Get the project files

1. Open your terminal.
2. Type the following commands:
    
    
    `git clone https://github.com/alvo254/orbit. cd orbit`
    
    This downloads the project and moves you into the project folder.

### 4. Initialize Terraform

In your terminal, still in the project folder, type:

`terraform init`

This sets up Terraform to work with OpenStack.

### 5. Plan your deployment

Let's see what Terraform is going to create. Type:

`terraform plan`

This shows you a list of all the resources Terraform will create.

### 6. Create your cloud resources

If the plan looks good, let's create everything! Type:

`terraform apply --auto-approve`


### 7. Access your virtual machine

After everything is created, Terraform will show you some information about your new resources. Look for a line that says something like:

`floating_ip = "ip"`

This is the public IP address of your new virtual machine. You can use SSH to connect to it:

Copy

`ssh -i orbit.pem root@<ip>`

Replace `ip with instance ip` with the actual IP address Terraform gave you.

## Customizing your setup

Want to change something? Here are some files you can modify:

- `main.tf`: This is where most of the resource definitions are.
- `variables.tf`: You can change default values here.

For example, to use a different size (flavor) for your virtual machine, find the `openstack_compute_instance_v2` resource in `main.tf` and change the `flavor_id`.


## Contributing

Contributions to improve the configuration or documentation are welcome. Please follow these steps:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request