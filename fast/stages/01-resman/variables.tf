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

# defaults for variables marked with global tfdoc annotations, can be set via
# the tfvars file generated in stage 00 and stored in its outputs

variable "automation" {
  # tfdoc:variable:source 00-bootstrap
  description = "Automation resources created by the bootstrap stage."
  type = object({
    outputs_bucket = string
    project_id     = string
    wif_pool       = string
    wif_providers = object({
      github = string
      gitlab = string
    })
  })
}

variable "billing_account" {
  # tfdoc:variable:source 00-bootstrap
  description = "Billing account id and organization id ('nnnnnnnn' or null)."
  type = object({
    id              = string
    organization_id = number
  })
}

variable "cicd_config" {
  description = "CI/CD configuration. Providers map to those set in the `automation` variable. Set to null to disable, or set individual repositories to null if not needed."
  type = object({
    repositories = object({
      data_platform_dev = object({
        branch   = string
        name     = string
        provider = string
      })
      data_platform_prod = object({
        branch   = string
        name     = string
        provider = string
      })
      networking = object({
        branch   = string
        name     = string
        provider = string
      })
      project_factory_dev = object({
        branch   = string
        name     = string
        provider = string
      })
      project_factory_prod = object({
        branch   = string
        name     = string
        provider = string
      })
      security = object({
        branch   = string
        name     = string
        provider = string
      })
    })
  })
  default = null
  # validate repositories
  validation {
    condition = var.cicd_config == null ? true : alltrue([
      for k, v in coalesce(var.cicd_config.repositories, {}) :
      v == null || try(v.name, null) != null
    ])
    error_message = "Non-null repositories need a non-null name."
  }
  validation {
    condition = var.cicd_config == null ? true : alltrue([
      for k, v in coalesce(var.cicd_config.repositories, {}) :
      # TODO: bring back gitlab once we have proper support for it
      # contains(["github", "gitlab"], try(v.provider, ""))
      v == null || try(v.provider, "") == "github"
    ])
    error_message = "Non-null repositories need a valid provider. Supported CI/CD providers: 'github'."
  }
}

variable "custom_roles" {
  # tfdoc:variable:source 00-bootstrap
  description = "Custom roles defined at the org level, in key => id format."
  type = object({
    service_project_network_admin = string
  })
  default = null
}

variable "groups" {
  # tfdoc:variable:source 00-bootstrap
  description = "Group names to grant organization-level permissions."
  type        = map(string)
  # https://cloud.google.com/docs/enterprise/setup-checklist
  default = {
    gcp-billing-admins      = "gcp-billing-admins",
    gcp-devops              = "gcp-devops",
    gcp-network-admins      = "gcp-network-admins"
    gcp-organization-admins = "gcp-organization-admins"
    gcp-security-admins     = "gcp-security-admins"
    gcp-support             = "gcp-support"
  }
}

variable "organization" {
  # tfdoc:variable:source 00-bootstrap
  description = "Organization details."
  type = object({
    domain      = string
    id          = number
    customer_id = string
  })
}

variable "organization_policy_configs" {
  description = "Organization policies customization."
  type = object({
    allowed_policy_member_domains = list(string)
  })
  default = null
}

variable "outputs_location" {
  description = "Enable writing provider, tfvars and CI/CD workflow files to local filesystem. Leave null to disable"
  type        = string
  default     = null
}

variable "prefix" {
  # tfdoc:variable:source 00-bootstrap
  description = "Prefix used for resources that need unique names. Use 9 characters or less."
  type        = string

  validation {
    condition     = try(length(var.prefix), 0) < 10
    error_message = "Use a maximum of 9 characters for prefix."
  }
}

variable "team_folders" {
  description = "Team folders to be created. Format is described in a code comment."
  type = map(object({
    descriptive_name     = string
    group_iam            = map(list(string))
    impersonation_groups = list(string)
  }))
  default = null
  # default = {
  #   team-a = {
  #     descriptive_name = "Team A"
  #     group_iam = {
  #       team-a-group@example.com = ["roles/owner", "roles/resourcemanager.projectCreator"]
  #     }
  #     impersonation_groups = ["team-a-admins@example.com"]
  #   }
  # }
}
