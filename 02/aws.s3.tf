resource "random_pet" "bucket" {
  length = 7
}

resource "aws_s3_bucket" "session_recording" {
  bucket = "boundary-session-recording-${random_pet.bucket.id}"
}
