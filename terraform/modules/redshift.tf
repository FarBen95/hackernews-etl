resource "aws_redshiftserverless_workgroup" "redshift_workgroup" {
  workgroup_name = "${var.project}-redshift-workgroup"
  namespace_name = aws_redshiftserverless_namespace.redshift_namespace.namespace_name
  base_capacity = var.redshift_base_capacity
  publicly_accessible = false
  security_group_ids = [aws_security_group.redshift_serverless_sg.id]
  subnet_ids = [aws_subnet.private_subnet.id]

  tags = {
    Name = "${var.project}-redshift-workgroup"
  }
}

resource "aws_redshiftserverless_namespace" "redshift_namespace" {
  namespace_name = "${var.project}-redshift-namespace"
  db_name = "${var.project}_db"
  admin_username = var.redshift_db_username
  admin_user_password = var.redshift_db_password
  iam_roles = [aws_iam_role.redshift_serverless_role.arn]

  tags = {
    Name = "${var.project}-redshift-namespace"
  }
}