/*
*
*  Api Gateway
* 
*/

module "api-gateway" {
  source           = "./modules/api-gateway"
  ENVIROMENT       = var.ENV
  APP_NAME         = var.APP_NAME
  AWS_REGION       = var.AWS_REGION
  KINESSIS_DF_ARN  = module.kinessis-data-firehouse.sg12_aws_kinesis_firehose_arn
  KINESSIS_DF_NAME = module.kinessis-data-firehouse.sg12_aws_kinesis_firehose_name
}


module "kinessis-data-firehouse" {
  source     = "./modules/kinessis-data-firehouse"
  ENVIROMENT = var.ENV
  APP_NAME   = var.APP_NAME
}


module "kinesis-data-analytics" {
  source                       = "./modules/kinesis-data-analytics"
  ENVIROMENT                   = var.ENV
  APP_NAME                     = var.APP_NAME
  KINESIS_FIREHOUSE_ARN        = module.kinessis-data-firehouse.sg12_aws_kinesis_firehose_arn
  KINESIS_FIREHOUSE_BUCKET_ARN = module.kinessis-data-firehouse.sg12_aws_kinesis_firehouse_bucket_arn
  KINESIS_FIREHOUSE_LAMBDA_ARN = module.kinessis-data-firehouse.sg12_aws_kinesis_firehouse_lambda_arn
  KINESIS_OUTPUT_FIREHOUSE_ARN = module.kinesis-data-firehouse-after-analytics.sg12_aws_kinesis_firehose_processed_arn

}


module "kinesis-data-firehouse-after-analytics" {
  source     = "./modules/kinesis-data-firehouse-after-analytics"
  ENVIROMENT = var.ENV
  APP_NAME   = var.APP_NAME
}
