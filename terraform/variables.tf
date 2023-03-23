variable "environnment_suffix" {
  type        = string
  description = "The suffix to append to the environment name"
}

variable "location" {
  type        = string
  description = "The location/region where all resources in this environment should be created"
  default     = "West Europe"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
  default     = "fleroux"
}

variable "app_port" {
  type        = number
  description = "The port of the web app"
}

variable "database_name" {
  type        = string
  description = "The name of the database"
}

variable "database_port" {
  type        = number
  description = "The port of the database"
  default     = 5432
}

variable "access_token_expiry" {
  type        = string
  description = "The duration of the access token"
  default     = "15m"
}

variable "refresh_token_expiry" {
  type        = string
  description = "The duration of the refresh token"
  default     = "7d"
}

variable "refresh_token_cookie_name" {
  type        = string
  description = "The name of the cookie used to store the refresh token"
}
