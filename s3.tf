resource "aws_s3_bucket" "testbucket" {
  bucket = "${var.my_enviroment}-test-bucket-terraform-123890"
  tags = {
    Name = "${var.my_enviroment}-test-bucket-terraform-123890"
  }
}
