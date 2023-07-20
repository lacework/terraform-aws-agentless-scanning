# v0.12.0

## Features
* feat(RAIN-54831): Add multi volume & scan stopped instances variable fields (#95) (Whitney Smith)([e0a9fbd](https://github.com/lacework/terraform-aws-agentless-scanning/commit/e0a9fbddc4bac2b3733da3fe87875faa0d882c78))
## Documentation Updates
* docs: Correction of the version constraints in README.md (#87) (bebold-jhr)([4a65bf1](https://github.com/lacework/terraform-aws-agentless-scanning/commit/4a65bf1d86685b74b6fabc857dcf14939dcb9777))
## Other Changes
* chore: Revert "feat (RAIN-54831) Add scan multi volume & scan stopped instances field options (#77)" (#94) (Whitney Smith)([ef6791b](https://github.com/lacework/terraform-aws-agentless-scanning/commit/ef6791b704afc6851d5bc6342ee389c1ec205231))
* ci: version bump to v0.11.4-dev (Lacework)([9d1d9ca](https://github.com/lacework/terraform-aws-agentless-scanning/commit/9d1d9caca9572df30d7ca9fc7dab55e6305363bb))
---
# v0.11.3

## Bug Fixes
* fix: remove ingress rule allowing traffic within sg (#90) (Joseph Wilder)([707d0e4](https://github.com/lacework/terraform-aws-agentless-scanning/commit/707d0e4a17b60b1243b7a5a89b2b3504e7dbed69))
## Documentation Updates
* docs(vars): match bucket_force_destroy description (#89) (Salim Afiune)([162ab5b](https://github.com/lacework/terraform-aws-agentless-scanning/commit/162ab5be376b922632f151e29734bcb9e72e90d4))
## Other Changes
* ci: version bump to v0.11.3-dev (Lacework)([23eb300](https://github.com/lacework/terraform-aws-agentless-scanning/commit/23eb300284eace325cb47a022568d4cb9b20fc6d))
---
# v0.11.2

## Bug Fixes
* fix: bump lacework provider min version to '~> 1.8' (#84) (Salim Afiune)([f2bef4d](https://github.com/lacework/terraform-aws-agentless-scanning/commit/f2bef4d0aa275cf2e8a208a3cce04077c60ccf1c))
## Other Changes
* ci: version bump to v0.11.2-dev (Lacework)([55b8344](https://github.com/lacework/terraform-aws-agentless-scanning/commit/55b83441d923a22ff8605309cc7987f5aae04b4c))
---
# v0.11.1

## Other Changes
* ci: version bump to v0.11.1-dev (Lacework)([8f94941](https://github.com/lacework/terraform-aws-agentless-scanning/commit/8f94941ace5979b038f6eea8c1e3455c9cfe46f4))
---
# v0.11.0

## Features
* feat: Add support for AWS provider 5.0 (#79) (Darren)([c8ecc52](https://github.com/lacework/terraform-aws-agentless-scanning/commit/c8ecc52fcffca51c5ff6760427138bd3ca5e9ba6))
## Bug Fixes
* fix: Removed check for suffix having more than 4 chars, because it doesn't prevent redeployments with same name which closes #71 (#74) (bebold-jhr)([58030f8](https://github.com/lacework/terraform-aws-agentless-scanning/commit/58030f86749b811a7cdcfd4e0dc4b060a7021f94))
## Other Changes
* ci: tfsec (#75) (jonathan stewart)([e9e06ff](https://github.com/lacework/terraform-aws-agentless-scanning/commit/e9e06ffd1fb1ff8d634073003fe49b1b88e32a35))
* ci: version bump to v0.10.1-dev (Lacework)([0459d9b](https://github.com/lacework/terraform-aws-agentless-scanning/commit/0459d9b95eaf815b209f343013adc4df046bbfac))
---
# v0.10.0

## Features
* feat: Allow usage of internet gateway to be optional (#69) (bebold-jhr)([e698584](https://github.com/lacework/terraform-aws-agentless-scanning/commit/e69858426f3c86af0bac97ba98426b6d88859d8d))
## Bug Fixes
* fix: s3 bucket ownership controls (#72) (djmctavish)([fc9cd81](https://github.com/lacework/terraform-aws-agentless-scanning/commit/fc9cd8150ca957a4bb0510dd4702b22328cefe5b))
## Other Changes
* ci: version bump to v0.9.3-dev (Lacework)([fc395ad](https://github.com/lacework/terraform-aws-agentless-scanning/commit/fc395ad20724ef8e3996d3c34232c5e56b2c48ca))
---
# v0.9.2

## Bug Fixes
* fix: Add kms:ViaService condition to KMS policy statements (#67) (Teddy Reed)([d2b4097](https://github.com/lacework/terraform-aws-agentless-scanning/commit/d2b409765cd2d1eedc4532de8abdfc241a7eed3c))
## Other Changes
* ci: version bump to v0.9.2-dev (Lacework)([dac17a8](https://github.com/lacework/terraform-aws-agentless-scanning/commit/dac17a8875ea869ccd28ef6e8db58aea5a4e4553))
---
# v0.9.1

## Bug Fixes
* fix: Ensure security group is passed to scan task via environment variable (Joseph Wilder)([761875c](https://github.com/lacework/terraform-aws-agentless-scanning/commit/761875c65d73d01fde513fc979133c7afbc6fbff))

## Other Changes
* ci: version bump to v0.9.1-dev (Lacework)([3dc2349](https://github.com/lacework/terraform-aws-agentless-scanning/commit/3dc2349b43fadce23305cbb3808bc0cb6baf73ea))
---
# v0.9.0

## Features
* feat: Add S3 SSE configuration options (#59) (Teddy Reed)([678aef5](https://github.com/lacework/terraform-aws-agentless-scanning/commit/678aef5a9dd1940d21fad3c366b96e84935e2f04))
* feat: Allow the user to pass additional custom environment variables to the ECS task (#60) (bebold-jhr)([1069a4e](https://github.com/lacework/terraform-aws-agentless-scanning/commit/1069a4eb8af10cb822d7a4ea6558ad4690cac8c8))
## Bug Fixes
* fix: Set ECS_CLUSTER_ARN within task_definition resource (#61) (Teddy Reed)([96812e3](https://github.com/lacework/terraform-aws-agentless-scanning/commit/96812e365d5aa0283daa54e18e45893c7e905b4b))
## Other Changes
* ci: version bump to v0.8.1-dev (Lacework)([2a57f40](https://github.com/lacework/terraform-aws-agentless-scanning/commit/2a57f40faab38713805dbfb96c130b1ff67b8fce))
---
# v0.8.0

## Features
* feat: allow use of existing network resources (#57) (Alan Nix)([279c87a](https://github.com/lacework/terraform-aws-agentless-scanning/commit/279c87a40886d603eacda1ba2d38a94a208f82e9))
## Bug Fixes
* fix: Remove AllowListSecrets Permissions from scan task policy  (#55) (Whitney Smith)([f7b4a40](https://github.com/lacework/terraform-aws-agentless-scanning/commit/f7b4a40d7e5c7431e24036e5aab45b377c4e22b2))
* fix: remove use the default security group (#52) (Alan Nix)([ac3f3b5](https://github.com/lacework/terraform-aws-agentless-scanning/commit/ac3f3b5769d2d316664a51ea0bcc4cc567df4e4d))
## Documentation Updates
* doc: adding workaround for update loop (#51) (Alan Nix)([5e96799](https://github.com/lacework/terraform-aws-agentless-scanning/commit/5e96799573aaddc562e84d34bb0f7ddab107fd4e))
## Other Changes
* ci: version bump to v0.7.2-dev (Lacework)([749fce2](https://github.com/lacework/terraform-aws-agentless-scanning/commit/749fce2cdc9ea29cb098a9fb85bf23060ef6ee4a))
---
# v0.7.1

## Bug Fixes
* fix: Add AWS recommended statements to enforce bucket SSE (#48) (Teddy Reed)([3bb426d](https://github.com/lacework/terraform-aws-agentless-scanning/commit/3bb426d96a9447bd6f8fb8e56cbcfaaec8e37c25))
## Documentation Updates
* docs: added an example for automatic snapshot role deployment (#49) (Alan Nix)([b659f7e](https://github.com/lacework/terraform-aws-agentless-scanning/commit/b659f7edac3844e2fa1f392a0f3d826ff7e47f6e))
* docs: Update readme, add examples, add CI tests for custom roles (#45) (Steve)([dc115f7](https://github.com/lacework/terraform-aws-agentless-scanning/commit/dc115f7230325640f52a690d329dc0e3fb0c4831))
## Other Changes
* ci: version bump to v0.7.1-dev (Lacework)([d9a6cd2](https://github.com/lacework/terraform-aws-agentless-scanning/commit/d9a6cd2d044e550077dd4153428f791383e2496a))
---
# v0.7.0

## Features
* feat: allow use of an existing VPC for deploying regional scan resources (#46) (Alan Nix)([da76d5c](https://github.com/lacework/terraform-aws-agentless-scanning/commit/da76d5c67278579a708cea35acbea4dc35ba7401))
* feat: add support for using existing IAM roles and policies (#44) (Steve)([febf745](https://github.com/lacework/terraform-aws-agentless-scanning/commit/febf745865f44a61830969c4e862a18ed417f62a))
## Other Changes
* ci: version bump to v0.6.1-dev (Lacework)([75c39a6](https://github.com/lacework/terraform-aws-agentless-scanning/commit/75c39a6c77ff72789e639fb7069815ce87381e3f))
---
# v0.6.0

## Features
* feat: Add default encryption and public access block to S3 (#40) (Teddy Reed)([cfd8c6d](https://github.com/lacework/terraform-aws-agentless-scanning/commit/cfd8c6d754cf101720fcfc28402ed1fadd6c7a1f))
## Other Changes
* ci: version bump to v0.5.2-dev (Lacework)([4caed03](https://github.com/lacework/terraform-aws-agentless-scanning/commit/4caed03fd53d081c8a33e803e46ef05db0e81d9c))
---
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
