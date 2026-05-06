#create ecr repository
resource "aws_ecr_repository" "memos_repo" {
  name = "ecsmemos"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

}

