<!-- BEGIN_TF_DOCS -->


## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_instance.hotwg_asne3_prod_1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_nat_ip"></a> [nat\_ip](#input\_nat\_ip) | terraform google\_compute\_address resource | `any` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | terraform google\_service\_account resource | `any` | n/a | yes |
| <a name="input_ssh_pub_key_file"></a> [ssh\_pub\_key\_file](#input\_ssh\_pub\_key\_file) | gce public key used by ssh file path | `any` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | terraform google\_compute\_subnetwortk resource | `any` | n/a | yes |
<!-- END_TF_DOCS -->