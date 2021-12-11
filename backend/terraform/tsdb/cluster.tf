locals {
  cluster_name = "${var.resource_prefix}_tsdb"
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name = local.cluster_name

  launch_configuration = aws_launch_configuration.launch_configuration.name

  vpc_zone_identifier = var.subnet_ids

  # Run a fixed number of instances in the ASG
  min_size         = var.cluster_size
  max_size         = var.cluster_size
  desired_capacity = var.cluster_size

  health_check_type         = "EC2"
  health_check_grace_period = 300
  wait_for_capacity_timeout = "10m"

  tags = flatten(
    [
      {
        key                 = "Name"
        value               = local.cluster_name
        propagate_at_launch = true
      },
      {
        key                 = "consul-clients"
        value               = local.cluster_name
        propagate_at_launch = true
      },
      [for key, value in var.tags : {
        key                 = key
        value               = value
        propagate_at_launch = true
      }],
    ]
  )

  lifecycle {
    # As of AWS Provider 3.x, inline load_balancers and target_group_arns
    # in an aws_autoscaling_group take precedence over attachment resources.
    # Since the consul-cluster module does not define any Load Balancers,
    # it's safe to assume that we will always want to favor an attachment
    # over these inline properties.
    #
    # For further discussion and links to relevant documentation, see
    # https://github.com/hashicorp/terraform-aws-vault/issues/210
    ignore_changes = [load_balancers, target_group_arns]
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  name_prefix   = "${local.cluster_name}_"
  image_id      = var.tsdb_ami
  instance_type = var.tsdb_instance_type
  user_data     = var.user_data
  key_name      = var.key_name

  security_groups             = [var.sg_id]
  associate_public_ip_address = true
  iam_instance_profile        = var.instance_profile

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.volume_size
    delete_on_termination = true
    encrypted             = false
  }

  # Important note: whenever using a launch configuration with an auto scaling group, you must set
  # create_before_destroy = true. However, as soon as you set create_before_destroy = true in one resource, you must
  # also set it in every resource that it depends on, or you'll get an error about cyclic dependencies (especially when
  # removing resources). For more info, see:
  #
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  # https://terraform.io/docs/configuration/resources.html
  lifecycle {
    create_before_destroy = true
  }
}