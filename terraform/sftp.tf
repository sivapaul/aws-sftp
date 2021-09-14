module "sftp" {
  source             = "./modules/aws_sftp"
  dynamo_table_name  = "dev-sftp-test"
  vpc_id             = var.vpc_id
  account_id         = var.account_id
  aws_region         = var.aws_region
  subnet_ids         = ["${var.public_subnet_a}","${var.public_subnet_b}","${var.public_subnet_c}"]
}