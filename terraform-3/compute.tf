resource "aws_launch_template" "my_template" {
  name_prefix            = "web-servers"
  image_id               = "ami-0b3c832b6b7289e44"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

resource "aws_autoscaling_group" "my_asg" {
  name                 = "my-asg"
  desired_capacity     = 3
  max_size             = 6
  min_size             = 3
  health_check_type    = "ec2"
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  launch_template {
    id      = aws_launch_template.my_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.alb_tg.arn]
}
