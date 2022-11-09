# v0.5.1

## Bug Fixes
* fix: Add more validations to organization inputs (#36) (Teddy Reed)([3eccaa5](https://github.com/lacework/terraform-aws-agentless-scanning/commit/3eccaa53b024c97dbe5d41fd24039c7fb3c57449))
* fix: Update Lacework provider requirement to 0.27 (#35) (Finn Ellis)([6ef952c](https://github.com/lacework/terraform-aws-agentless-scanning/commit/6ef952c8b2b6291151b4ea5d49b6748246eadd4f))
## Documentation Updates
* docs: update Lacework provider version in readme (#39) (Darren)([778886d](https://github.com/lacework/terraform-aws-agentless-scanning/commit/778886d0320f1bebe52754552ac62dbb6ced16b6))
## Other Changes
* chore: update Lacework provider version to v1 (#38) (Darren)([c9bd456](https://github.com/lacework/terraform-aws-agentless-scanning/commit/c9bd456151961af61de2377f9f1a04851e6dd3c5))
* ci: version bump to v0.5.1-dev (Lacework)([367daa4](https://github.com/lacework/terraform-aws-agentless-scanning/commit/367daa43e120111175eb23ec6e4a250db3ca8594))
---
# v0.5.0

## Features
* feat: Add AWS Org integration or multi-account mode (#33) (Teddy Reed)([5b466ca](https://github.com/lacework/terraform-aws-agentless-scanning/commit/5b466ca4b9bde1ec05554e62c0e71c5ec23d0841))
* feat: Allow VPC CIDR to be set (#32) (Teddy Reed)([fc5864c](https://github.com/lacework/terraform-aws-agentless-scanning/commit/fc5864c4c6804a8662ae7d5d25e9c30f277ce8b6))
* feat: Add option to encrypt Secrets Manager secret using KMS Customer Managed Key (#31) (Matthew Grotheer)([b220d45](https://github.com/lacework/terraform-aws-agentless-scanning/commit/b220d4546ff3a5695798920f6172f1a700d5ab62))
## Other Changes
* ci: version bump to v0.4.1-dev (Lacework)([fc6875a](https://github.com/lacework/terraform-aws-agentless-scanning/commit/fc6875a09d7c0e6fc291a123eeace16fcc733ab6))
---
# v0.4.0

## Features
* feat: Add global_module_reference input (#29) (Teddy Reed)([fd8ba06](https://github.com/lacework/terraform-aws-agentless-scanning/commit/fd8ba0655c219b0bf76384b17a54af5dd069c265))
## Other Changes
* ci: version bump to v0.3.5-dev (Lacework)([d8869dd](https://github.com/lacework/terraform-aws-agentless-scanning/commit/d8869ddf56185e2d1a114621b3c0360372168b0e))
---
# v0.3.4

## Bug Fixes
* fix: Changed security group configuration to match CloudFormation (#26) (Alan Nix)([8bf7406](https://github.com/lacework/terraform-aws-agentless-scanning/commit/8bf7406b3e9a45a8fee7134010f93374c80f2ef4))
## Other Changes
* chore: formatting consistency and terraform-docs output (#27) (Alan Nix)([9b94fa1](https://github.com/lacework/terraform-aws-agentless-scanning/commit/9b94fa188b902eb67746edae9df6d9dc5a9c8b2e))
* ci: version bump to v0.3.4-dev (Lacework)([283a550](https://github.com/lacework/terraform-aws-agentless-scanning/commit/283a550108c8705002782366cfc6fa4963e990d3))
---
# v0.3.3

## Bug Fixes
* fix: Update bucket policy to correct object ARN (#24) (Teddy Reed)([cf8fe77](https://github.com/lacework/terraform-aws-agentless-scanning/commit/cf8fe77374081960216a5e999623af4ee7422b12))
## Documentation Updates
* docs(examples): Update examples for 0.3.2 usage (#23) (Teddy Reed)([c31ffad](https://github.com/lacework/terraform-aws-agentless-scanning/commit/c31ffada9399b0cf93f82adc53275e0ebfc0d8f4))
## Other Changes
* ci: version bump to v0.3.3-dev (Lacework)([be8900e](https://github.com/lacework/terraform-aws-agentless-scanning/commit/be8900e760694a6bee0a6f30c092086552b76781))
---
# v0.3.2

## Bug Fixes
* fix: Update with CloudFormation on-demand scan policies (#21) (Teddy Reed)([9986ef5](https://github.com/lacework/terraform-aws-agentless-scanning/commit/9986ef56682c479752d7b6b75842758a8c0373c8))
* fix: Output the suffix and prefix values (#20) (Teddy Reed)([c7b67a3](https://github.com/lacework/terraform-aws-agentless-scanning/commit/c7b67a3afc7afa0aa2adba1b65e5b059967534a2))
## Other Changes
* ci: version bump to v0.3.2-dev (Lacework)([8d4ecdb](https://github.com/lacework/terraform-aws-agentless-scanning/commit/8d4ecdb369ee8bf8e195c7e42199fa60bbd8c2f9))
---
# v0.3.1

## Bug Fixes
* fix: Remove global-only example (#18) (Teddy Reed)([20f3a15](https://github.com/lacework/terraform-aws-agentless-scanning/commit/20f3a15649322e8e52302be0a892933763b3a8c9))
* fix: ignore out-of-band updates to ECS cluster tags (#17) (Alan Nix)([a0600ae](https://github.com/lacework/terraform-aws-agentless-scanning/commit/a0600ae4d14c31f5bbb3e48de817b154074393c2))
## Other Changes
* ci: version bump to v0.3.1-dev (Lacework)([166f469](https://github.com/lacework/terraform-aws-agentless-scanning/commit/166f4699410f1b3532c8b62d014e5ba5a44f3762))
---
# v0.3.0

## Features
* feat: added the ability to dynamically fetch the Lacework account name (#13) (Alan Nix)([7d4640f](https://github.com/lacework/terraform-aws-agentless-scanning/commit/7d4640fe7cb44ca123aa866bb62d1ddb4df0f9b4))
## Refactor
* refactor: address beta review changes (#14) (Darren)([4f70549](https://github.com/lacework/terraform-aws-agentless-scanning/commit/4f705490630d06027ec72e02fd98735d633bc44a))
## Other Changes
* ci: version bump to v0.2.3-dev (Lacework)([4371846](https://github.com/lacework/terraform-aws-agentless-scanning/commit/43718467467fd58bd74367fc94a7acb49e17d679))
---
# v0.2.2

## Other Changes
* ci: version bump to v0.2.2-dev (Lacework)([5c01154](https://github.com/lacework/terraform-aws-agentless-scanning/commit/5c0115421f38be3e261bb5515a2a9573014d9844))
---
# v0.2.1

## Bug Fixes
* fix: Update readme and examples with required inputs (#9) (Teddy Reed)([b2db7eb](https://github.com/lacework/terraform-aws-agentless-scanning/commit/b2db7eb89444d0d49de2fd3985cd4f0b42bcf877))
## Documentation Updates
* docs: update documentation (Darren Murray)([00d57f9](https://github.com/lacework/terraform-aws-agentless-scanning/commit/00d57f9f4e79ad875e53107cf29eecbebbaa0c41))
## Other Changes
* ci: version bump to v0.2.1-dev (Lacework)([6c85a41](https://github.com/lacework/terraform-aws-agentless-scanning/commit/6c85a415e8c12b57d954c93fd65cdfbd14bb666b))
---
# v0.2.0

## Features
* feat: pass credentials to lacework_integration_aws_agentless_scanning resource (#8) (Darren)([8cb1815](https://github.com/lacework/terraform-aws-agentless-scanning/commit/8cb1815b2e5fca36e9d0594616e9e4a626943a8c))
* feat: agentless scanning terraform module (#1) (Darren)([068ba95](https://github.com/lacework/terraform-aws-agentless-scanning/commit/068ba950a6fe1a25b20033de472acaa709d2fb5f))
## Bug Fixes
* fix: release script (#6) (Darren)([c468b26](https://github.com/lacework/terraform-aws-agentless-scanning/commit/c468b2612dadeb7c0bad7ba1c4fab70331c9af03))
## Documentation Updates
* docs: Update Readme (Darren Murray)([50e4e97](https://github.com/lacework/terraform-aws-agentless-scanning/commit/50e4e9731959e889a8d13a86e79e9dfc12542d00))
---
