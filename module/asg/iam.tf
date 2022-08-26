resource "aws_iam_role" "main" {
  name               = "${var.env_code}-s3-role"
  assume_role_policy = file("assumerole.json")
}

/*
resource "aws_iam_policy" "main" {
  name        = "${var.env_code}-s3-policy"
  description = "S3 bucket full access"
  policy      = file("s3bucket.json")
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}
*/
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "main" {
  name = var.env_code
  role = aws_iam_role.main.name
}
