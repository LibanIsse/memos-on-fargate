#create ecr repository
resource "aws_ecr_repository" "memos_repo" {
  name = "ecsmemos"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

}

