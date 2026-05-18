module "vpc" {
  source                = "./modules/vpc"
  vpc_cidr              = var.vpc_cidr
  vpc_name              = var.vpc_name
  public_subnet_1       = var.public_subnet_1
  public_subnet_2       = var.public_subnet_2
  private_subnet_1      = var.private_subnet_1
  private_subnet_2      = var.private_subnet_2
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
  a_z_1                 = var.a_z_1
  a_z_2                 = var.a_z_2
}

module "alb" {
  source             = "./modules/alb"
  alb_sg_id          = module.vpc.alb_security_group_id
  public_subnet_1_id = module.vpc.public_subnet_1_id
  public_subnet_2_id = module.vpc.public_subnet_2_id
  vpc_id             = module.vpc.vpc_name_id
  certificate_arn    = module.acm.certificate_arn
}

module "rds" {
  source              = "./modules/rds"
  task_sg             = module.vpc.task_sg_id
  private_subnet_1_id = module.vpc.private_subnet_1_id
  private_subnet_2_id = module.vpc.private_subnet_2_id
  vpc_id              = module.vpc.vpc_name_id
}

module "ecr" {
  source = "./modules/ecr"
}

module "iam" {
  source = "./modules/iam"
}

module "ecs" {
  source              = "./modules/ecs"
  execution_role_arn  = module.iam.ecs_task_execution_role_arn
  private_subnet_1_id = module.vpc.private_subnet_1_id
  private_subnet_2_id = module.vpc.private_subnet_2_id
  task_sg_id          = module.vpc.task_sg_id
  target_group_arn    = module.alb.alb_tg_arn
  memos_dsn           = module.rds.memos_dsn
}

module "acm" {
  source = "./modules/acm"
}

module "route53" {
  source = "./modules/route53"

  hosted_zone_name = var.hosted_zone_name
  record_name      = "tm"
  alb_dns_name     = module.alb.alb_dns_name
  alb_zone_id      = module.alb.alb_zone_id
}