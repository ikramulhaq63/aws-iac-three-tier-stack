# NETWORKING MODULES
module "networking" {
    source = "../../modules/networking"
    vpc_cidr = var.vpc_cidr
    project_name = var.project_name
    public_subnet_1_cidr = var.public_subnet_1_cidr
    public_subnet_2_cidr = var.public_subnet_2_cidr
    availability_zone_1 = var.availability_zone_1
    availability_zone_2 = var.availability_zone_2
    private_subnet_1_app_cidr = var.private_subnet_1_app_cidr
    private_subnet_2_app_cidr = var.private_subnet_2_app_cidr
    private_subnet_1_db_cidr = var.private_subnet_1_db_cidr
    private_subnet_2_db_cidr = var.private_subnet_2_db_cidr
}

# Module Security
module "security" {
  source = "../../modules/security"
  vpc_id = module.networking.vpc_id
  project_name = var.project_name
  depends_on = [ module.networking ]
}

# Web Tier Module
module "web_tier" {
  source = "../../modules/web-tier"
  project_name = var.project_name
  vpc_id = module.networking.vpc_id
  key_pair_name = module.security.key_pair_name
  ami_id = module.security.amazon_linux_2_ami_id
  instance_type = var.web_instance_type
  web_security_group_id = module.security.web_security_group_id
  depends_on = [module.networking, module.security]
  public_subnet_1_id = module.networking.public_subnet_1_id
  public_subnet_2_id = module.networking.public_subnet_2_id
  min_size              = var.web_min_size
  max_size              = var.web_max_size
  desired_capacity      = var.web_desired_capacity
  cpu_target_value      = 50.0
}


# ============================================
# APPLICATION TIER MODULE
# ============================================

module "app-tier" {
  source = "../../modules/app-tier"
  project_name = var.project_name
  vpc_id                   = module.networking.vpc_id
  public_subnet_1_id = module.networking.public_subnet_1_id
  private_subnet_app_tier_1_id = module.networking.private_subnet_app_tier_1_id
  private_subnet_app_tier_2_id = module.networking.private_subnet_app_tier_2_id
  app_security_group_id    = module.security.app_security_group_id
  bastion_security_group_id = module.security.bastion_security_group_id
  key_pair_name            = module.security.key_pair_name
  ami_id                   = module.security.amazon_linux_2_ami_id
  instance_type            = var.app_instance_type
  min_size                 = var.app_min_size
  max_size                 = var.app_max_size
  desired_capacity         = var.app_desired_capacity
  cpu_target_value         = 50.0
}

# ============================================
# DATABASE TIER MODULE
# ============================================
module "database_tier" {
  source = "../../modules/database-tier"

  project_name           = var.project_name
  private_subnet_db_tier_1_id  = module.networking.private_subnet_db_tier_1_id
  private_subnet_db_tier_2_id =  module.networking.private_subnet_db_tier_2_id
  db_security_group_id   = module.security.db_security_group_id
  db_engine              = var.db_engine
  db_engine_version      = var.db_engine_version
  db_instance_class      = var.db_instance_class
  db_allocated_storage   = 20
  db_max_allocated_storage = 100
  backup_retention_period = 7
  deletion_protection    = false
  skip_final_snapshot    = true

  depends_on = [module.networking, module.security]
}