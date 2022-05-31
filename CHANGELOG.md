# Changelog

All notable changes to this project will be documented in this file.

# [1.5.0](https://github.com/nuvibit/terraform-aws-lambda/compare/1.4.1...1.5.0) (2022-05-31)


### Features

* enable xray tracing for lambda functions and implement tfsec best practices ([dbc870f](https://github.com/nuvibit/terraform-aws-lambda/commit/dbc870ff32d85716d87414820303945e74018ea0))

## [1.4.1](https://github.com/nuvibit/terraform-aws-lambda/compare/1.4.0...1.4.1) (2022-03-29)


### Bug Fixes

* adding package source handling ([#17](https://github.com/nuvibit/terraform-aws-lambda/issues/17)) ([7502cd6](https://github.com/nuvibit/terraform-aws-lambda/commit/7502cd6ea62251abe63c48c9598a1660b65bba4e))

# [1.4.0](https://github.com/nuvibit/terraform-aws-lambda/compare/1.3.0...1.4.0) (2022-02-15)


### Features

* adding optional sqs trigger ([#14](https://github.com/nuvibit/terraform-aws-lambda/issues/14)) ([9f4a00a](https://github.com/nuvibit/terraform-aws-lambda/commit/9f4a00ac66e1c89e43cfa670c067fbfd6c209e63))

# [1.3.0](https://github.com/nuvibit/terraform-aws-lambda/compare/1.2.0...1.3.0) (2022-01-20)


### Features

* **aws_iam_role:** adding path support for lambda execution role ([#13](https://github.com/nuvibit/terraform-aws-lambda/issues/13)) ([0da1b22](https://github.com/nuvibit/terraform-aws-lambda/commit/0da1b2252c54974dae823dee459334524a7b5e13))

# [1.2.0](https://github.com/nuvibit/terraform-aws-lambda/compare/1.1.4...1.2.0) (2021-12-01)


### Bug Fixes

* **action:** fixing env var [skip ci] ([0133b24](https://github.com/nuvibit/terraform-aws-lambda/commit/0133b2484fbc2f35ba6bc8005e05b841de65679a))
* **action:** upgrade node version ([c0852ca](https://github.com/nuvibit/terraform-aws-lambda/commit/c0852cacb31bed945bc80b0ba24cfd5c2ddf7a91))
* **readme:** update submodule docs ([aba3c35](https://github.com/nuvibit/terraform-aws-lambda/commit/aba3c35cdc0484f14aa8d22ab91a894e8a517946))
* **realeaserc:** migrate to main branch ([8ce9185](https://github.com/nuvibit/terraform-aws-lambda/commit/8ce918524de1e3ade8f8da7bcc4e7aab0fb8f3b2))


### Features

* adding optional external lambda execution role ([d94c6fc](https://github.com/nuvibit/terraform-aws-lambda/commit/d94c6fc88e190474fd6ff3be7dfee65390342aa2))

## [1.1.4](https://github.com/nuvibit/terraform-aws-lambda/compare/1.1.3...1.1.4) (2021-08-10)


### Bug Fixes

* renaming statement id to allow multiple equal principals ([#8](https://github.com/nuvibit/terraform-aws-lambda/issues/8)) ([9144f3e](https://github.com/nuvibit/terraform-aws-lambda/commit/9144f3e07c15af20c440e3378d613dc3b129b6f8))
* revert commit directly to master branch [skip ci] ([79f96d5](https://github.com/nuvibit/terraform-aws-lambda/commit/79f96d576b94624856d36b1fd5696f1ee235f50e))

## [1.1.3](https://github.com/nuvibit/terraform-aws-lambda/compare/1.1.2...1.1.3) (2021-07-23)


### Bug Fixes

* changing log group policy to inline policy for better compatibility ([#6](https://github.com/nuvibit/terraform-aws-lambda/issues/6)) ([01bc15f](https://github.com/nuvibit/terraform-aws-lambda/commit/01bc15f892ec08e95c171a55a069c5997aa43e3e))

## [1.1.2](https://github.com/nuvibit/terraform-aws-lambda/compare/1.1.1...1.1.2) (2021-07-23)


### Bug Fixes

* error in format ([#5](https://github.com/nuvibit/terraform-aws-lambda/issues/5)) ([c28ba75](https://github.com/nuvibit/terraform-aws-lambda/commit/c28ba75e68d31d15c74e251dd4f950217e4c0d8c))

## [1.1.1](https://github.com/nuvibit/terraform-aws-lambda/compare/1.1.0...1.1.1) (2021-07-23)


### Bug Fixes

* **variables:** error in validation ([#4](https://github.com/nuvibit/terraform-aws-lambda/issues/4)) ([3afbdfa](https://github.com/nuvibit/terraform-aws-lambda/commit/3afbdfa355dc2dcdec5e737ab97d6f412b5968ee))

# [1.1.0](https://github.com/nuvibit/terraform-aws-lambda/compare/1.0.0...1.1.0) (2021-07-22)


### Features

* Add optional allowed triggers for service principals and optional permissions boundary ([#2](https://github.com/nuvibit/terraform-aws-lambda/issues/2)) ([eab8cc2](https://github.com/nuvibit/terraform-aws-lambda/commit/eab8cc283339645ee031aeb3c25980ac8203e51e))

# 1.0.0 (2021-07-15)


### Features

* initial commit ([f93d711](https://github.com/nuvibit/terraform-aws-lambda/commit/f93d711cc5fb658f81240034df2dadd9f8994767))
