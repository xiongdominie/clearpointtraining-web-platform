resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github_actions.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:xiongdominie@257389628/clearpointtraining-web-platform@1315388341:ref:refs/heads/main"
      ]
    }

  }
}

resource "aws_iam_role" "github_actions" {
  name = "clearpointtraining-cicd-role"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

data "aws_ecr_repository" "project1_website" {
  name = "project1-website"
}

data "aws_iam_policy_document" "github_actions_permissions" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [
      data.aws_ecr_repository.project1_website.arn
    ]
  }

  statement {
    actions = [
      "ssm:SendCommand"
    ]

    resources = [
      aws_instance.web.arn,
      "arn:aws:ssm:${var.aws_region}::document/AWS-RunShellScript"
    ]
  }

}

resource "aws_iam_policy" "github_actions" {
  name   = "clearpointtraining-github-actions-policy"
  policy = data.aws_iam_policy_document.github_actions_permissions.json

}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}



