/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module "automation-tf-output-gcs" {
  source     = "../../../modules/gcs"
  project_id = module.automation-project.project_id
  name       = "iac-core-outputs-0"
  prefix     = local.prefix
  versioning = true
  depends_on = [module.organization]
}

resource "google_storage_bucket_object" "actions" {
  for_each = local.cicd_actions
  bucket   = module.automation-tf-output-gcs.name
  # FIXME(jccb) do we need the action suffix?
  name    = "actions/${each.key}-action.yml"
  content = each.value
}

resource "google_storage_bucket_object" "providers" {
  for_each = local.providers
  bucket   = module.automation-tf-output-gcs.name
  # FIXME(jccb) do we need the providers suffix?
  name    = "providers/${each.key}-providers.tf"
  content = each.value
}

resource "google_storage_bucket_object" "tfvars" {
  bucket  = module.automation-tf-output-gcs.name
  name    = "tfvars/00-bootstrap.auto.tfvars.json"
  content = jsonencode(local.tfvars)
}

resource "google_storage_bucket_object" "tfvars_globals" {
  bucket  = module.automation-tf-output-gcs.name
  name    = "tfvars/globals.auto.tfvars.json"
  content = jsonencode(local.tfvars_globals)
}
