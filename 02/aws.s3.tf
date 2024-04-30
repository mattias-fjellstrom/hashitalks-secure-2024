resource "aws_s3_bucket" "session_recording" {
  bucket = "hug-boundary-session-recording"
  tags = {
    hug = "true"
  }
}
