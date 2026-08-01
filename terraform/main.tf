provider "aws" {
  region = "us-east-1"
}

#checkov:skip=CKV2_AWS_64:Politica de KMS no requerida en lab educativo
resource "aws_kms_key" "clave_bucket" {
  description         = "Llave KMS para cifrado del bucket del lab"
  enable_key_rotation = true
}

#checkov:skip=CKV_AWS_18:Logging de bucket no requerido en lab educativo
#checkov:skip=CKV_AWS_144:Replicacion cross-region no requerida en lab educativo
resource "aws_s3_bucket" "bucket_seguro" {
  bucket = "mi-bucket-devsecops-demo-12345"
}

resource "aws_s3_bucket_public_access_block" "publico" {
  bucket                  = aws_s3_bucket.bucket_seguro.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cifrado" {
  bucket = aws_s3_bucket.bucket_seguro.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.clave_bucket.arn
    }
  }
}

resource "aws_s3_bucket_versioning" "versionado" {
  bucket = aws_s3_bucket.bucket_seguro.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ciclo_vida" {
  bucket = aws_s3_bucket.bucket_seguro.id
  rule {
    id     = "expiracion-lab"
    status = "Enabled"
    expiration {
      days = 365
    }
  }
}

#checkov:skip=CKV2_AWS_5:Security group de referencia para el lab, no asociado a instancia real
resource "aws_security_group" "sg_seguro" {
  name        = "sg_ssh_restringido"
  description = "Grupo de seguridad restringido para lab"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}
