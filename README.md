# aws-meetup-2022-11-08

How do you know you are compliant? AWS Config will tell you when you deployed your infrastructure! Isn't it better to prevent non-compliant resources to be deployed in the first place? Let's see how we can use preventive and detective tools together.

## The idea

- Use cfn-guard for local validation
- Use same rule in AWS Config

## Demo

**Manual step**

```bash
make test
```

**git commit**

```bash
git add .
git commit
```

**Deploy the template**


```bash
make deploy SKIP_TEST=1
```

Force deploy

```bash
make deploy SKIP_TEST=1
```


## Prerequisites

This project requires [Python v3.9](https://www.python.org/) or newer and [poetry](https://python-poetry.org/). The rest of the dependencies will be encapsulated in the virtual environment that poetry will maintain for you.

```bash
brew install python3 poetry
```

## Before you start

Install all dependencies by executing the following command:

```bash
make install
```

## Build

To only perform a build you can use the following command, the output will be stored under a `.aws-sam` folder.

```bash
make build
```

## Deploy

To deploy make sure you have selected an `AWS_PROFILE` or that you have loaded the access keys in your session.

```bash
make deploy
```

## Destroy

To remove the deployed resources execute the following:

```bash
make deploy
```

## Cleanup

To remove the virtual environment created by poetry execute:

```bash
make cleanup
```
