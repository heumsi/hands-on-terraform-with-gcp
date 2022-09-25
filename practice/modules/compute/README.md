<!-- BEGIN_TF_DOCS -->


## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.34.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_instance.hotwg_asne3_prod_1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | terraform google\_service\_account resource | `any` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | terraform google\_compute\_subnetwortk resource | `any` | n/a | yes |
<!-- END_TF_DOCS -->