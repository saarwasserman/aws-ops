
# AWS Load Balancer Controller Helm Release
# used for managing AWS Load Balancer Controller in EKS 

# https://github.com/kubernetes-sigs/aws-load-balancer-controller
resource "helm_release" "lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.13.3"

  values = [
    <<-EOF
    clusterName: ${module.eks.cluster_name}
    region: ${var.region}
    vpcId: ${module.vpc.vpc_id}
    serviceAccount.create: false
    serviceAccount.name: aws-load-balancer-controller
    EOF
  ]

  depends_on = [aws_iam_role_policy_attachment.lb_controller_role_policy]
}

resource "aws_iam_policy" "lb_controller_policy" {
  name        = "LBControllerPolicy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Action": [
            "acm:DescribeCertificate",
            "acm:ListCertificates",
            "elasticloadbalancing:*",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcs",
            "ec2:DescribeRouteTables",
            "ec2:DescribeInstances",
            "ec2:DescribeInternetGateways",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeNetworkInterfaces",
            "iam:ListServerCertificates",
            "iam:GetServerCertificate",
            "iam:ListAttachedRolePolicies",
            "iam:GetRole",
            "iam:ListRoles",
            "iam:AttachRolePolicy",
            "iam:DetachRolePolicy"
        ],
        "Resource": "*"
        }
    ]
})
}

resource "aws_iam_role" "lb_controller_role" {
  name = "AWSLoadBalancerControllerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lb_controller_role_policy" {
  policy_arn = aws_iam_policy.lb_controller_policy.arn
  role       = aws_iam_role.lb_controller_role.name
}
