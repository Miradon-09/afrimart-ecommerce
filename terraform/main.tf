# main.tf

module "vpc" {
  source             = "./modules/vpc"
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
}

module "security" {
  source       = "./modules/security"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "database" {
  source               = "./modules/database"
  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.database_subnet_group_name
  db_security_group_id = module.security.db_sg_id
  cache_subnet_group   = module.vpc.elasticache_subnet_group_name
  cache_security_group = module.security.cache_sg_id
  db_username          = var.db_username
  db_password          = var.db_password
}

module "storage" {
  source       = "./modules/storage"
  project_name = var.project_name
}

module "loadbalancer" {
  source          = "./modules/loadbalancer"
  project_name    = var.project_name
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  security_groups = [module.security.alb_sg_id]
}

module "compute" {
  source        = "./modules/compute"
  project_name  = var.project_name
  web_sg_id     = module.security.web_sg_id
  jenkins_sg_id = module.security.jenkins_sg_id
  ami_id        = "ami-0e349888043265b96" # Amazon Linux 2
  instance_type = "t3.micro"
  key_name      = var.key_name

  # NEW: Pass these variables
  private_subnets = module.vpc.private_subnet_ids
  public_subnets  = module.vpc.public_subnet_ids
  elb_id          = module.loadbalancer.elb_id

  backend_repo_url  = module.ecr.backend_repository_url
  frontend_repo_url = module.ecr.frontend_repository_url
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}