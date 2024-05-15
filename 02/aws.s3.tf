resource "random_pet" "bucket" {
  length = 2
}

resource "aws_s3_bucket" "session_recording" {
  bucket = "boundary-session-recording-${random_pet.bucket.id}"
}
