## aws-sftp
This project is to deploy a HA SFTP solution using cloud(AWS) services which is HA and highly reloable and secure.

## Modules
1. IoC\
   a. Terraform SFTP solution\
   b. Terraform SFTP custom authentication\
2. NodeJS app to manage SFTP users
3. SFTP antivirus scan ***Pending***

## Why this is called HA, Reliable and Secure?
1. Backbone of AWS SFTP service is S3 which is a highly reliable service
2. SFTP file can be transferred for processing using lambda on S3 event trigger so we can get rid of traditional cronjobs
3. Data are stored on encrypted at rest which provide additional security
4. Only whitelisted IP are allowed to login per SFTP client

## Architecture 
![Architecture](https://github.com/sivapaul/aws-sftp/blob/main/arch/arch.png)