resource "aws_s3_bucket" "data-dump-bucket" {
  bucket = "${local.name_prefix}data-dump-bucket"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.capstone_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket" "resources-bucket" {
  bucket = "${local.name_prefix}resources-bucket"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.capstone_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket" "data-stage-bucket" {
  bucket = "${local.name_prefix}data-stage-bucket"
  server_side_encryption_configuration {
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.capstone_key.arn
      sse_algorithm     = "aws:kms"
      }
    }
  }
}

/*not used since hospital data csv errors in glue
resource "aws_s3_bucket_object" "hospital" {
  bucket = aws_s3_bucket.data-dump-bucket.bucket
  key    = "/hospital-data/hospital-data.csv"
  source = "../data/hospital-data.csv"
}

resource "aws_s3_bucket_object" "covid_data" {
  bucket = aws_s3_bucket.data-stage-bucket.bucket
  key    = "/covid-data/covid-data_sample.csv"
  source = "../data/covid-data.csv"
}
*/
resource "aws_s3_bucket_object" "python_package" {
  bucket = aws_s3_bucket.resources-bucket.bucket
  key    = "python/python.zip"
  kms_key_id = aws_kms_key.capstone_key.id
  #remove initial / from key?
  source = "../python_scripts/python.zip"
}

resource "aws_s3_bucket_object" "python_download_script" {
  bucket = aws_s3_bucket.resources-bucket.bucket
  key    = "python/script_download_covid.zip"
  kms_key_id = aws_kms_key.capstone_key.id
  source = "../python_scripts/script_download_covid.zip"
}

resource "aws_s3_bucket_object" "python_download_hospitals_script" {
  bucket = aws_s3_bucket.resources-bucket.bucket
  key    = "python/script_download_hospitals.zip"
  kms_key_id = aws_kms_key.capstone_key.id
  source = "../python_scripts/script_download_hospitals.zip"
}

resource "aws_s3_bucket_object" "python_transform_script" {
  bucket = aws_s3_bucket.resources-bucket.bucket
  key    = "python/script_transform_covid_v${var.script_version}.zip"
  kms_key_id = aws_kms_key.capstone_key.id
  source = "../python_scripts/script_transform_covid_v${var.script_version}.zip"
}

resource "aws_s3_bucket_object" "python_transform_hospitals_script" {
  bucket = aws_s3_bucket.resources-bucket.bucket
  key    = "python/script_transform_hospitals.zip"
  kms_key_id = aws_kms_key.capstone_key.id
  source = "../python_scripts/script_transform_hospitals.zip"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.data-dump-bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.transform_covid_data_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "raw-zone/covid-data-"
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_s3_bucket_notification" "bucket_notification_hospitals" {
  bucket = aws_s3_bucket.data-dump-bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.transform_hospitals_data_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "raw-zone/hospitals-data-"
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_bucket_hospitals]
}