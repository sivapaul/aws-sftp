module "sftp" {
  source             = "./modules/aws_sftp"
  dynamo_table_name  = "dev-sftp-test"
  vpc_id             = var.vpc_id
  account_id         = var.account_id
  aws_region         = var.aws_region
  subnet_ids         = ["${var.public_subnet_a}","${var.public_subnet_b}","${var.public_subnet_c}"]
}

module "sftp-auth" {
  source           = "./modules/sftp-auth"
  lambda_exe_arn   = module.sftp.sftp_lambda_exe_arn
  vpc_id           = var.vpc_id
  account_id       = var.account_id
  aws_region       = var.aws_region
  sftp_server_id   = module.sftp.sftp_server_id
  sftp_dynamo_name = module.sftp.sftp_dynamo_name
  api_sg_id        = ["${module.sftp.api_sg_id}"]
  subnetid         = ["${var.private_subnet_a}","${var.private_subnet_b}","${var.private_subnet_c}"]
}